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

    func processIncommingCall(callId: UUID, callerId _: String, displayName: String) async {
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: displayName)
        callUpdate.hasVideo = true
        callUpdate.localizedCallerName = displayName
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.supportsHolding = true

//        do {
//            try await callProvider.reportNewIncomingCall(with: UUID(), update: update)
        callProvider.reportCall(with: callId, updated: callUpdate)
//        } catch {
//            Logger().error("[GWPCallManagerService] Incoming VoIP call failed: \(error.localizedDescription)")
//            callProvider.reportCall(with: UUID(), endedAt: Date.now, reason: .failed)
//        }
    }
}

extension GPWCallManagerService: CXProviderDelegate {
    func providerDidReset(_: CXProvider) {
        Logger().debug("[GPWAppDelegate] Provider did reset")
    }

    func provider(_: CXProvider, perform action: CXAnswerCallAction) {
        Logger().debug("[GPWAppDelegate] Call answered")
        action.fulfill()
    }

    func provider(_: CXProvider, perform action: CXEndCallAction) {
        Logger().debug("[GPWAppDelegate] Call ended")
        action.fail()
    }

//    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
//        Logger().debug("[GPWAppDelegate] Call was \(action.isOnHold ? "" : "un")held")
//        action.fulfill()
//    }

    func provider(_: CXProvider, perform action: CXSetMutedCallAction) {
        Logger().debug("[GPWAppDelegate] Call was \(action.isMuted ? "" : "un")muted")
        action.fulfill()
    }
}
