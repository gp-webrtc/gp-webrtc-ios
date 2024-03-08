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
import Foundation
import os.log
import PushKit
import WebRTC

class GPWCallManagerService: NSObject {
    static var shared: GPWCallManagerService {
        if let _instance { return _instance }
        else {
            _instance = GPWCallManagerService()
            return _instance!
        }
    }

    private static var _instance: GPWCallManagerService?

    let callProvider: CXProvider
    private var _queue: DispatchQueue?
//    let defaultCallUpdate: CXCallUpdate

    override init() {
        // 1. Call provider
        let config = CXProviderConfiguration()
        config.supportsVideo = false
        config.supportedHandleTypes = [.generic]
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.includesCallsInRecents = true
        // config.ringtoneSound = "ES_CellRingtone23.mp3"
        callProvider = CXProvider(configuration: config)
        
//        // Default call update
//        defaultCallUpdate = CXCallUpdate()
//        defaultCallUpdate.remoteHandle = CXHandle(type: .generic, value: "Unknown")
//        defaultCallUpdate.hasVideo = false
//        defaultCallUpdate.localizedCallerName = "Unknown"
//        defaultCallUpdate.supportsGrouping = false
//        defaultCallUpdate.supportsUngrouping = false
//        defaultCallUpdate.supportsHolding = false
//        defaultCallUpdate.supportsDTMF = false

        super.init()
    }
    
    var queue: DispatchQueue {
        get { return _queue! }
        set {
            if _queue == nil {
                _queue = newValue
                callProvider.setDelegate(self, queue: newValue)
            } else {
                assertionFailure("The queue should be set once")
            }
        }
    }

    func processIncomingCall(with payload: PKPushPayload) async -> String? {
        guard let callId = payload.dictionaryPayload["callId"] as? String,
              let callId = UUID(uuidString: callId),
              let callerId = payload.dictionaryPayload["callerId"] as? String,
              let displayName = payload.dictionaryPayload["displayName"] as? String
        else {
            Logger().error("[GPWCallManagerService] Missing callId, callerId or displayName, reporting failed call")
            await reportFailedCall()
            return nil
        }
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: "unknown")
        callUpdate.localizedCallerName = "Connection..."

        do {
            // Report call ASAP
            Logger().info("[GWPCallManagerService] Reporting incoming VoIP call \(callId.uuidString)")
            try await callProvider.reportNewIncomingCall(with: callId, update: callUpdate)
            
            // Update the details
            callUpdate.remoteHandle = CXHandle(type: .generic, value: callerId)
            callUpdate.localizedCallerName = displayName
            callUpdate.hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool ?? false
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.supportsHolding = false
            callUpdate.supportsDTMF = false
            callProvider.reportCall(with: callId, updated: callUpdate)
            Logger().info("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) updated")
            
            return callId.uuidString
        } catch {
            Logger().error("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) failed: \(error.localizedDescription)")
            return callId.uuidString
        }
    }
    
    //    func processIncomingCall(with callId: UUID, payload: PKPushPayload) async {
    //        // Parse payload and update, or close call
    //        if let callerId = payload.dictionaryPayload["callerId"] as? String,
    //           let displayName = payload.dictionaryPayload["displayName"] as? String
    //        {
    //            let callUpdate = CXCallUpdate()
    //            callUpdate.hasVideo = true
    //            callUpdate.remoteHandle = CXHandle(type: .generic, value: callerId)
    //            callUpdate.localizedCallerName = displayName
    //            callUpdate.supportsGrouping = false
    //            callUpdate.supportsUngrouping = false
    //            callUpdate.supportsHolding = false
    //            callUpdate.supportsDTMF = false
    //            callProvider.reportCall(with: callId, updated: callUpdate)
    //            Logger().info("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) updated")
    //        } else {
    //            callProvider.reportCall(with: callId, endedAt: .now, reason: .failed)
    //            Logger().error("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) failed: unable to get callerId and/or displayName")
    //
    //        }
    //    }
    
    func reportFailedCall() async {
        let callId = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = .init(type: .generic, value: "unknown")
        update.localizedCallerName = "Unknonw"
        
        try? await callProvider.reportNewIncomingCall(with: callId, update: update)
        callProvider.reportCall(with: callId, endedAt: Date.now, reason: .failed)
    }

}

extension GPWCallManagerService: CXProviderDelegate {
    func providerDidReset(_: CXProvider) {
        Logger().debug("[GPWCallManagerService] Provider did reset")
    }

    func provider(_: CXProvider, perform action: CXAnswerCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) answered (action)")

        action.fulfill()
    }

    func provider(_: CXProvider, perform action: CXEndCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) ended (action)")

        action.fail()
    }

    func provider(_: CXProvider, perform action: CXSetMutedCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) was \(action.isMuted ? "" : "un")muted (action)")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate _: AVAudioSession) {
        Logger().debug("[GPWCallManagerService] Audio session has activated")
    }
    
    func provider(_ provider: CXProvider, didDeactivate _: AVAudioSession) {
        Logger().debug("[GPWCallManagerService] Audio session has deactivated")
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        Logger().debug("[GPWCallManagerService] Call provided did begin")
    }
}
