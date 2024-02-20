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

import Foundation
import os.log
import PushKit

// MARK: - PKPushRegistryDelegate

extension GPWAppDelegate: PKPushRegistryDelegate {
    func configurePushKit() {
        let voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    func pushRegistry(_: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == .voIP {
            let deviceToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
            Logger().debug("[GPWAppDelegate] PushKit VoIP device token: \(deviceToken)")
            GPWUserNotificationService.shared.setVOIPToken(deviceToken)
        }
    }

    func pushRegistry(_: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        if type == .voIP {
            Logger().debug("[GPWAppDelegate] Invalidated VoIP push credentials")
            GPWUserNotificationService.shared.setVOIPToken(nil)
        }
    }

    func pushRegistry(_: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) async {
        if type == .voIP {
            Logger().debug("[GPWAppDelegate] Received incomming VoIP push")
            Logger().debug("[GPWAppDelegate] VoIP payload: \(payload.dictionaryPayload)")

            if let callerId = payload.dictionaryPayload["callerId"] as? String,
               let callId = payload.dictionaryPayload["callId"] as? String,
               let callId = UUID(uuidString: callId),
               let displayName = payload.dictionaryPayload["displayNameId"] as? String
            {
                await GPWCallManagerService.shared.processIncommingCall(
                    callId: callId,
                    callerId: callerId,
                    displayName: displayName
                )
            }
        }
    }
}
