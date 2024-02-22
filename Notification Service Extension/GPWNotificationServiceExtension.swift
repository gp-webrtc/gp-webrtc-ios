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

import CallKit
import os.log
import UserNotifications

class GPWNotificationServiceExtension: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler

        if let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) {
            Logger().info("[GPWNotificationService] Received \(bestAttemptContent.categoryIdentifier) notification")
            switch bestAttemptContent.categoryIdentifier {
                case "USER_DEVICE_ADDED":
                    Logger().info("[GPWNotificationService] Transfered to the app")
                    contentHandler(bestAttemptContent)
                    return

                case "USER_CALL_RECEIVED":
                    guard let callId = bestAttemptContent.userInfo["callId"] as? String,
                          let callerId = bestAttemptContent.userInfo["callerId"] as? String,
                          let displayName = bestAttemptContent.userInfo["displayName"] as? String
                    else {
                        Logger().error("[GPWNotificationService] Missing VoIP call details (callId, callerId or displayName)")
                        return
                    }

                    Logger().info("[GPWNotificationService] Received incoming VoIP call \(callId)")

                    CXProvider.reportNewIncomingVoIPPushPayload([
                        "callId": callId,
                        "callerId": callerId,
                        "displayName": displayName,
                    ]) { error in
                        if let error {
                            Logger().error("[GPWNotificationService] Unable to report new incoming VOIP call: \(error.localizedDescription)")
                            return
                        }
                    }
                    contentHandler(UNNotificationContent())

                default:
                    Logger().error("[GPWNotificationService] Unhandled notification received \(bestAttemptContent.categoryIdentifier)")
                    contentHandler(UNNotificationContent())
                    return
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
