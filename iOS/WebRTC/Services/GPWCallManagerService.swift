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

    private let callProvider: CXProvider
//    private var timeoutTimers: [UUID:Timer] = [:]

    override init() {
        let config = CXProviderConfiguration()
        config.supportsVideo = false
        config.supportedHandleTypes = [.generic]
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.includesCallsInRecents = true
        //            config.ringtoneSound = "ES_CellRingtone23.mp3"

        callProvider = CXProvider(configuration: config)

        super.init()

        callProvider.setDelegate(self, queue: nil)
    }

    func processIncomingCall(with payload: PKPushPayload) async {
        let callId = UUID()
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: "Unknown")

        do {
            // Report call ASAP
            try await callProvider.reportNewIncomingCall(with: callId, update: callUpdate)
            Logger().info("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) reported")

            // Parse payload and update, or close call
            if let callerId = payload.dictionaryPayload["callerId"] as? String,
               let displayName = payload.dictionaryPayload["displayName"] as? String
            {
                callUpdate.hasVideo = true
                callUpdate.remoteHandle = CXHandle(type: .generic, value: callerId)
                callUpdate.localizedCallerName = displayName
                callUpdate.supportsGrouping = false
                callUpdate.supportsUngrouping = false
                callUpdate.supportsHolding = false
                callUpdate.supportsDTMF = false
                callProvider.reportCall(with: callId, updated: callUpdate)
                Logger().info("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) updated")
            }
        } catch {
            callProvider.reportCall(with: callId, endedAt: .now, reason: .failed)
            Logger().error("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) failed: \(error.localizedDescription)")
        }
    }

//    func processIncommingCall(with callId: UUID, callerId: String, displayName: String) async {
//        let callUpdate = CXCallUpdate()
//        callUpdate.remoteHandle = CXHandle(type: .generic, value: callerId)
//
//        do {
//            try await callProvider.reportNewIncomingCall(with: callId, update: callUpdate)
//            callUpdate.hasVideo = true
//            callUpdate.localizedCallerName = displayName
//            callUpdate.supportsGrouping = false
//            callUpdate.supportsUngrouping = false
//            callUpdate.supportsHolding = false
//            callUpdate.supportsDTMF = false
//            callProvider.reportCall(with: callId, updated: callUpdate)
    ////            Logger().info("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) reported")
    ////            startTimeoutTimer(callId: callId)
//        } catch {
//            callProvider.reportCall(with: callId, endedAt: .now, reason: .failed)
    ////            Logger().error("[GWPCallManagerService] Incoming VoIP call \(callId.uuidString) failed: \(error.localizedDescription)")
//        }
//    }

//    func reportFakeCall() async {
//        let callId = UUID()
//        let callUpdate = CXCallUpdate()
//        callUpdate.remoteHandle = CXHandle(type: .generic, value: "dummy")
    ////        callUpdate.hasVideo = true
//        callUpdate.localizedCallerName = "Fake call"
    ////        callUpdate.supportsGrouping = false
    ////        callUpdate.supportsUngrouping = false
    ////        callUpdate.supportsHolding = false
    ////        callUpdate.supportsDTMF = false
//
//        try? await callProvider.reportNewIncomingCall(with: callId, update: callUpdate)
//        callProvider.reportCall(with: callId, endedAt: .now, reason: .failed)
    ////        Logger().warning("[GWPCallManagerService] Incoming VoIP call reported as failed")
//    }

//    private func startTimeoutTimer(callId: UUID) {
//        guard timeoutTimers[callId] == nil else { return }
//
//        timeoutTimers[callId] = .scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
//            Logger().warning("[GPWCallManagerService] Call \(callId.uuidString) was unanswered")
//            self.
//        }
//    }
//
//    private func cancelTimeoutTimer(callId: UUID) {
//        guard let timeoutTimer = timeoutTimers[callId] else { return }
//
//        timeoutTimer.invalidate()
//        timeoutTimers.removeValue(forKey: callId)
//    }
}

extension GPWCallManagerService: CXProviderDelegate {
    func providerDidReset(_: CXProvider) {
        Logger().debug("[GPWCallManagerService] Provider did reset")
    }

    func provider(_: CXProvider, perform action: CXAnswerCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) answered (action)")

//        cancelTimeoutTimer(callId: action.callUUID)

        action.fulfill()
    }

    func provider(_: CXProvider, perform action: CXEndCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) ended (action)")

//        cancelTimeoutTimer(callId: action.callUUID)

        action.fail()
    }

    //    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    //        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) was \(action.isOnHold ? "" : "un")held")
    //        action.fulfill()
    //    }

    func provider(_: CXProvider, perform action: CXSetMutedCallAction) {
        Logger().debug("[GPWCallManagerService] Call \(action.callUUID.uuidString) was \(action.isMuted ? "" : "un")muted (action)")
        action.fulfill()
    }
}
