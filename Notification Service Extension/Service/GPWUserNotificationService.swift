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
import UserNotifications
import os.log

class GPWUserNotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // If unencrypted, simply forward
        guard request.content.categoryIdentifier == "org.gpfister.republik.encrypted"  else {
            contentHandler(request.content)
            return
        }
        
        // Decrypt category identifier
        guard let content = bestAttemptContent,
              let encryptedCategoryIdentifier = content.userInfo["encryptedCategoryIdentifier"] as? String,
              let categoryIdentifierData = Data(base64Encoded: encryptedCategoryIdentifier),
              let categoryIdentifier = String(data: categoryIdentifierData, encoding: .utf8)
        else {
            Logger().error("[GPWNotificationService] Unable to decrypt encryptedCategoryIdentifier")
            return
        }
        
        guard let encryptedPayload = content.userInfo["encryptedPayload"] as? String,
              let encryptedPayloadData = encryptedPayload.data(using: .utf8),
              let payloadData = Data(base64Encoded: encryptedPayloadData)
        else {
            Logger().error("[GPWNotificationService] Unable to process encryptedPayload of notification with category \(categoryIdentifier)")
            return
        }
        
        Logger().debug("[GPWNotificationService] Processing notification \(categoryIdentifier)")
        Logger().debug("[GPWNotificationService] Received encryptedPayload \(encryptedPayload)")
        Logger().debug("[GPWNotificationService] Received payload \(String(data: payloadData, encoding: .utf8) ?? "nil")")
        
        if categoryIdentifier == "org.gpfister.republik.userDeviceAdded",
           let payload = try? JSONDecoder().decode(GPWUserDeviceAddedNotificationContent.self, from: payloadData),
           let userInfoData = try? JSONEncoder().encode(payload.userInfo),
           let userInfo = try? JSONSerialization.jsonObject(with: userInfoData, options: []) as? [String: Any] {
            
            content.categoryIdentifier = categoryIdentifier
            content.title = payload.title
            content.subtitle = payload.subtitle
            content.userInfo = userInfo
            
            // Pass to the app user notification, unencrypted
            contentHandler(content)
        } else if categoryIdentifier == "org.gpfister.republik.userCallReceived",
                  let payload = try? JSONDecoder().decode(GPWUserCallReceivedNotificationContent.self, from: payloadData),
                  let userInfoData = try? JSONEncoder().encode(payload.userInfo),
                  let userInfo = try? JSONSerialization.jsonObject(with: userInfoData, options: []) as? [String: Any] {
                
            // Pass to the app push kit voip notification, unencrypted
            CXProvider.reportNewIncomingVoIPPushPayload(userInfo) { error in
                if let error {
                    Logger().error("[GPWNotificationService] Unable to report notification to CXProvider: \(error.localizedDescription)")
                    return
                }
            }
        } else {
            Logger().error("[GPWNotificationService] Unable to process payload of notification \(categoryIdentifier)")
            return
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
