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
final class GPWUserNotificationViewModel: ObservableObject {
    @Published var isLoading = true

//    @GPSCPublishedUserDefault(\.userPushNotificationOnboarding) private var userPushNotificationOnboarding
    @GPSCPublishedUserDefault(\.userNotificationRegistrationTokenId) private var userNotificationRegistrationTokenId

//    private var fcmRegistrationToken: String?
    private var cancellables = Set<AnyCancellable>()
    private var userNotificationService = GPWUserNotificationService.shared
    private var userNotificationRegistrationTokenService = GPWCKUserNotificationRegistrationTokenService.shared

    func subscribe(userId: String) {
        // Determine FCM registration token (when authorized) or get rid of registered token (if denied)
        Publishers.CombineLatest(userNotificationService.authorizationStatus, $userNotificationRegistrationTokenId)
            .sink { authorizationStatus, userNotificationRegistrationTokenId in
                if let authorizationStatus {
                    self.isLoading = false

                    switch authorizationStatus {
                        case .authorized:
                            if userNotificationRegistrationTokenId == nil { self.userNotificationRegistrationTokenId = UUID().uuidString }

                            guard let userNotificationRegistrationTokenId else { return }
                            Logger().debug("[GPWUserNotificationViewModel] Notification registration token id: \(userNotificationRegistrationTokenId)")
                        case .denied:
                            if let userNotificationRegistrationTokenId {
                                Task {
                                    do {
                                        Logger().debug("[GPWUserNotificationViewModel] Deleting FCM registration token")
                                        try await self.userNotificationRegistrationTokenService.delete(userNotificationRegistrationTokenId, userId: userId)
//                                        self.fcmRegistrationToken = nil
                                    } catch {
                                        Logger().error("[GPWUserNotificationViewModel] Unable to upload FCM register token: \(error.localizedDescription)")
                                    }
                                }
                                self.userNotificationRegistrationTokenId = nil
                            }
                        default:
                            break
                    }
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest4($isLoading, $userNotificationRegistrationTokenId, userNotificationService.apnsToken, userNotificationService.voipToken)
            .sink { isLoading, userNotificationRegistrationTokenId, apnsToken, voipToken in
                guard !isLoading,
                      let userNotificationRegistrationTokenId,
                      let apnsToken,
                      let voipToken
                else {
                    Logger().debug("[GPWUserNotificationViewModel] Some conditions not met to upload FCM registration token: isLoading = \(isLoading), tokenId = \(userNotificationRegistrationTokenId ?? "nil"), apnsToken: \(apnsToken ?? "nil"), voipToken: \(voipToken ?? "nil")")
                    return
                }

                // TODO: Check if tokens are different

                Task {
                    do {
                        Logger().debug("[GPWUserNotificationViewModel] Uploading FCM registration token")
                        try await self.userNotificationRegistrationTokenService
                            .insertOrUpdate(
                                GPWCKUserNotificationDeviceToken(
                                    apnsToken: GPWCKUserNotificationDeviceAPNSToken(
                                        apns: apnsToken,
                                        voip: voipToken
                                    )
                                ),
                                userId: userId,
                                tokenId: userNotificationRegistrationTokenId
                            )
                    } catch {
                        Logger().error("[GPWUserNotificationViewModel] Unable to upload FCM register token: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)
    }

    func unsubcribe() {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

//    func requestAuthorization(application: UIApplication) async throws -> Bool {
//        return try await userNotificationService.requestAuthorization(application: application)
//    }
}
