//
// gp-webrtc-ios/swift-cloud-kit
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

#if canImport(FirebaseMessaging)
import Combine
import FirebaseMessaging
import os.log
import SwiftUI
import UserNotifications

public class GPWCKCloudMessagingService: NSObject, MessagingDelegate {
    //        public let userId: String
    //        public let tokenId: String

    private var _apnsToken: Data?

    public var apnsToken: Data? {
        get { _apnsToken }
        set {
            if _apnsToken != newValue {
                _apnsToken = newValue
                if let _apnsToken {
                    Messaging.messaging().setAPNSToken(_apnsToken, type: .prod)
                    //                        Messaging.messaging().token { token, error in
                    //                            if let error {
                    //                                Logger().error("[GPWCKCloudMessagingService] Could not fetch FCM registration token: \(error)")
                    //                            } else if let token {
                    //                                Logger().debug("[GPWCKCloudMessagingService] Received FCM registration token: \(token)")
                    //                            }
                    //                        }
                }
            }
        }
    }

    override public init() {
        //        public init(userId: String, tokenId: String) {
        //            self.userId = userId
        //            self.tokenId = tokenId
        super.init()

        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
    }

    public func messaging(_: Messaging, didReceiveRegistrationToken token: String?) {
        Task {
//            do {
            Logger().info("[GPWCKCloudMessagingService] Received FCM registration token: \(token ?? "nil")")
//                if let token {
//                    try await GPWCKUserFCMRegistrationTokenService()
//                        .insertOrUpdate(token, userId: self.userId, tokenId: self.tokenId)
//                } else {
//                    try await GPWCKUserFCMRegistrationTokenService()
//                        .delete(tokenId, userId: userId)
//                }
//            } catch {
//                Logger().error("[GPWCKCloudMessagingService] could not \(token != nil ? "insert or update" : "delete") token: \(error.localizedDescription)")
//            }
        }
    }

    public func appDidReceiveMessage(_ message: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(message)
    }
}
#endif
