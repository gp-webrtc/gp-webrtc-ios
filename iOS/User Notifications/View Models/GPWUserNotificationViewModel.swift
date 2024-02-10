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

class GPWUserNotificationViewModel: ObservableObject {
    @GPSCPublishedUserDefault(\.userFCMRegistrationTokenId) private var userFCMRegistrationTokenId

    private var token: String?
    private var cancellables = Set<AnyCancellable>()
    private var userNotificationService = GPWUserNotificationService.shared
    private var userFCMRegistrationTokenService = GPWCKUserFCMRegistrationTokenService.shared

    init() {}

    deinit {
        self.unsubcribe()
    }

    func subscribe(userId: String) {
        userNotificationService.fcmRegistrationToken.combineLatest($userFCMRegistrationTokenId)
            .sink { token, tokenId in
                if token != self.token {
                    if let token {
                        let tokenId = tokenId ?? UUID().uuidString
                        Task {
                            do {
                                Logger().debug("[GPWUserNotificationViewModel] Uploading FCM registration token")
                                try await self.userFCMRegistrationTokenService.insertOrUpdate(token, userId: userId, tokenId: tokenId)
                                self.token = token
                                if self.userFCMRegistrationTokenId != tokenId { self.userFCMRegistrationTokenId = tokenId }
                            } catch {
                                Logger().error("[GPWUserNotificationViewModel] Unable to upload FCM register token: \(error.localizedDescription)")
                            }
                        }
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
}
