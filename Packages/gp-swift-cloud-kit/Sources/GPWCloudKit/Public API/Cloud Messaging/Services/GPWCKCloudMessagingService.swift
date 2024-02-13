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
    public static var shared: GPWCKCloudMessagingService {
        if let _instance { return _instance }
        else {
            _instance = GPWCKCloudMessagingService()
            return _instance!
        }
    }

    private var _apnsToken: Data?
    private static var _instance: GPWCKCloudMessagingService?

    private var fcmRegistrationTokenSubject = CurrentValueSubject<String?, Never>(nil)

    override private init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    public var apnsToken: Data? {
        get { _apnsToken }
        set {
            // First time
            if _apnsToken == nil, let newValue {
                Messaging.messaging().setAPNSToken(newValue, type: .prod)
                Messaging.messaging().token { token, error in
                    if let error {
                        Logger().error("[GPWCKCloudMessagingService] Unable to fetching FCM registration token: \(error)")
                        return
                    }

                    print("[GPWCKCloudMessagingService] Fetched FCM registration token: \(token ?? "nil")")
                    self.fcmRegistrationTokenSubject.send(token)
                }
            } else if _apnsToken != nil, newValue == nil {
                if let _apnsToken {
                    Messaging.messaging().setAPNSToken(_apnsToken, type: .sandbox)
                } else {
                    Messaging.messaging().deleteData { error in
                        if let error {
                            Logger().error("[GPWCKCloudMessagingService] Unable to delete data: \(error.localizedDescription)")
                            return
                        }
                        Logger().debug("[GPWCKCloudMessagingService] Data deleted")
                    }
                }
            }
            _apnsToken = newValue
        }
    }

//    public func refreshFCMRegistrtionToken() {
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                Logger().error("[GPWCKCloudMessagingService] Unable to fetching FCM registration token: \(error)")
//                return
//            }
//
//            print("[GPWCKCloudMessagingService] Fetched FCM registration token: \(token ?? "nil")")
//            self.fcmRegistrationTokenSubject.send(token)
//        }
//    }

    public lazy var fcmRegistrationToken = fcmRegistrationTokenSubject.eraseToAnyPublisher()

    public func messaging(_: Messaging, didReceiveRegistrationToken token: String?) {
        Logger().debug("[GPWCKCloudMessagingService] Refreshed FCM registration token: \(token ?? "nil")")
        fcmRegistrationTokenSubject.send(token)
    }

    public func appDidReceiveMessage(_ message: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(message)
    }
}
#endif
