//
// gp-webrtc-ios
// Copyright (c) 2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Combine
import Foundation
import GPStorageKit
import GPWCloudKit
import os.log
import UIKit
import UserNotifications

@MainActor
final class GPWUserNotificationViewModel: GPWCKUserObservableObject {
    @Published var isLoading = true
    
    @GPSKPublishedUserDefault(\.userNotificationTokenId) private var userNotificationTokenId
    
    private var snapshotListener: GPWCKSnapshotListener?
    private var cancellables = Set<AnyCancellable>()
    
    private var authService = GPWCKAuthService.shared
    private var userNotificationService = GPWUserNotificationService.shared
    private var userNotificationTokenService = GPWCKUserNotificationTokenService.shared
    private var userNotificationTokenSubject = CurrentValueSubject<GPWCKUserNotificationToken?, Never>(nil)
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.unsubcribe()
        }
    }
    
    func subscribe(userId: String) {
        Logger().debug("[GPWUserNotificationViewModel] Subscribing")
        isLoading = true
        Publishers.CombineLatest(userNotificationService.authorizationStatus, $userNotificationTokenId)
            .sink { authorizationStatus, userNotificationTokenId in
                if let authorizationStatus {
                    
                    switch authorizationStatus {
                    case .authorized:
                        Logger().debug("[GPWUserNotificationViewModel] Notification are authorized")
                        if userNotificationTokenId == nil {
                            if let snapshotListener = self.snapshotListener {
                                snapshotListener.remove()
                                self.snapshotListener = nil
                            }
                            self.userNotificationTokenId = UUID().uuidString
                        }
                        
                        guard let userNotificationTokenId = userNotificationTokenId ?? self.userNotificationTokenId else {
                            return
                        }
                        
                        Logger().debug("[GPWUserNotificationViewModel] User notification token id: \(userNotificationTokenId)")
                        
                        if self.snapshotListener == nil {
                            self.snapshotListener = self.userNotificationTokenService.documentSnapshot(userNotificationTokenId, of: userId) { userNotificationToken, error in
                                if let error {
                                    Logger().debug("[GPWUserNotificationViewModel] Unable to get to user notification token: \(error.localizedDescription)")
                                    return
                                }
                                
                                self.userNotificationTokenSubject.send(userNotificationToken)
                                
                                self.isLoading = false
                                
                                if let userNotificationToken {
                                    Logger().debug("[GPWUserNotificationViewModel] Received user notification registration token \(userNotificationToken.tokenId)")
                                } else {
                                    Logger().debug("[GPWUserNotificationViewModel] No user notification registration token")
                                }
                            }
                        }
                        
                        break
                    case .denied:
                        Logger().debug("[GPWUserNotificationViewModel] Notification are denied")
                        if let userNotificationTokenId {
                            Task {
                                do {
                                    Logger().debug("[GPWUserNotificationViewModel] Deleting user notification token")
                                    try await self.userNotificationTokenService.delete(userNotificationTokenId, userId: userId)
                                } catch {
                                    Logger().error("[GPWUserNotificationViewModel] Unable to upload user notification token: \(error.localizedDescription)")
                                }
                            }
                            self.userNotificationTokenId = nil
                        }
                    default:
                        Logger().debug("[GPWUserNotificationViewModel] Notification status is neither authorized nor denied")
                        break
                    }
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4(
            $isLoading,
            $userNotificationTokenId,
            userNotificationTokenSubject.eraseToAnyPublisher(),
            Publishers.CombineLatest(
                userNotificationService.apnsToken,
                userNotificationService.voipToken
            ).eraseToAnyPublisher()
        )
        .sink { (isLoading, userNotificationTokenId, userNotificationToken, tokens) in
            let (apnsToken, voipToken) = tokens
            guard !isLoading,
                  let userNotificationTokenId,
                  let apnsToken,
                  let voipToken
            else {
                Logger().debug("[GPWUserNotificationViewModel] Some conditions not met to upload user notification token")
                Logger().debug("[GPWUserNotificationViewModel]   - isLoading = \(isLoading ? "true" : "false") (should be 'false')")
                Logger().debug("[GPWUserNotificationViewModel]   - userNotificationTokenId = \(userNotificationTokenId ?? "nil") (should not be 'nil')")
                Logger().debug("[GPWUserNotificationViewModel]   - apnsToken: \(apnsToken ?? "nil") (should not be 'nil')")
                Logger().debug("[GPWUserNotificationViewModel]   - voipToken: \(voipToken ?? "nil") (should not be 'nil')")
                return
            }
            
            // Register new token if any data changed, or if older than 7 days
            Task {
                do {
                    if let userNotificationToken,
                       (    apnsToken != userNotificationToken.deviceToken.apnsToken.apns ||
                            voipToken != userNotificationToken.deviceToken.apnsToken.voip ||
                            (userNotificationToken.modificationDate ?? Date.now) <= (Date.now - (7 * 24 * 3600)) // 7 days
                       ) {
                        Logger().debug("[GPWUserNotificationViewModel] Updating existing user notification token \(userNotificationTokenId)")
                        try await self.insertOrUpdateUserNotificationToken(userNotificationTokenId, for: userId, apnsToken: apnsToken, voipToken: voipToken)
                    } else if userNotificationToken == nil {
                        Logger().debug("[GPWUserNotificationViewModel] Registering new user notification token \(userNotificationTokenId)")
                        try await self.insertOrUpdateUserNotificationToken(userNotificationTokenId, for: userId, apnsToken: apnsToken, voipToken: voipToken)
                    }
                } catch {
                    Logger().error("[GPWUserNotificationViewModel] Unable to upload user notification register token: \(error.localizedDescription)")
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func unsubcribe() {
        Logger().debug("[GPWUserNotificationViewModel] Unsubscribing")
        for cancellable in cancellables {
            cancellable.cancel()
        }
        
        if let snapshotListener {
            snapshotListener.remove()
            self.snapshotListener = nil
        }
    }
    
    private func insertOrUpdateUserNotificationToken(_ tokenId: String, for userId: String, apnsToken: String, voipToken: String) async throws {
        try await self.userNotificationTokenService
            .insertOrUpdate(
                GPWCKUserNotificationDeviceToken(
                    apnsToken: GPWCKUserNotificationDeviceAPNSToken(
                        apns: apnsToken,
                        voip: voipToken,
                        environment: UIDevice.current.pushEnvironment
                    )
                ),
                userId: userId,
                tokenId: tokenId
            )
    }
    
    func authServiceWillDeleteUser(_ authService: GPWCloudKit.GPWCKAuthService) throws {
        if let snapshotListener {
            snapshotListener.remove()
            self.snapshotListener = nil
        }
    }
}
