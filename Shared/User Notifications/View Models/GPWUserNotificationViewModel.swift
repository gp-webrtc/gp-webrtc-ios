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
    @GPSCPublishedUserDefault(\.userFCMRegistrationTokenId) private var userFCMRegistrationTokenId

    private var fcmRegistrationToken: String?
    private var cancellables = Set<AnyCancellable>()
    private var userNotificationService = GPWUserNotificationService.shared
    private var userFCMRegistrationTokenService = GPWCKUserFCMRegistrationTokenService.shared

    func subscribe(userId: String) {
        // Determine FCM registration token (when authorized) or get rid of registered token (if denied)
        Publishers.CombineLatest(userNotificationService.authorizationStatus, $userFCMRegistrationTokenId)
            .sink { authorizationStatus, userFCMRegistrationTokenId in
                if let authorizationStatus {
                    self.isLoading = false

                    switch authorizationStatus {
                        case .authorized:
                            if userFCMRegistrationTokenId == nil { self.userFCMRegistrationTokenId = UUID().uuidString }

                            guard let userFCMRegistrationTokenId else { return }
                            Logger().debug("[GPWUserNotificationViewModel] FCM token registration id: \(userFCMRegistrationTokenId)")
                        case .denied:
                            if let userFCMRegistrationTokenId {
                                Task {
                                    do {
                                        Logger().debug("[GPWUserNotificationViewModel] Deleting FCM registration token")
                                        try await self.userFCMRegistrationTokenService.delete(userFCMRegistrationTokenId, userId: userId)
                                        self.fcmRegistrationToken = nil
                                    } catch {
                                        Logger().error("[GPWUserNotificationViewModel] Unable to upload FCM register token: \(error.localizedDescription)")
                                    }
                                }
                                self.userFCMRegistrationTokenId = nil
                            }
                        default:
                            break
                    }
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3($isLoading, $userFCMRegistrationTokenId, userNotificationService.fcmRegistrationToken)
            .sink { isLoading, userFCMRegistrationTokenId, fcmRegistrationToken in
                guard !isLoading, let userFCMRegistrationTokenId, let fcmRegistrationToken, fcmRegistrationToken != self.fcmRegistrationToken else {
                    Logger().debug("[GPWUserNotificationViewModel] Some conditions not met to upload FCM registration token: isLoading = \(isLoading), tokenId = \(userFCMRegistrationTokenId ?? "nil"), token: \(fcmRegistrationToken ?? "nil")")
                    return
                }

                Task {
                    do {
                        Logger().debug("[GPWUserNotificationViewModel] Uploading FCM registration token")
                        try await self.userFCMRegistrationTokenService.insertOrUpdate(fcmRegistrationToken, userId: userId, tokenId: userFCMRegistrationTokenId)
                        self.fcmRegistrationToken = fcmRegistrationToken
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

    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await userNotificationService.requestAuthorization()
        if isAuthorized {
            try await userNotificationService.registerForRemoteNotifications()
        }
        return isAuthorized
    }
}
