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
import GPWCloudKit
import os.log

@MainActor
final class GPWCoreStatusViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var hasTimedOut = false
    @Published var maintenanceMode = false

    private let coreStatusService = GPWCKCoreStatusService.shared

    private var snapshotListner: GPWCKSnapshotListener?
    private var timeoutTimer: Timer?

    func subscribe() {
        Logger().debug("[GPWCoreStatusViewModel] Subscribing")
        isLoading = true
        guard snapshotListner == nil, timeoutTimer == nil else { return }

        snapshotListner = coreStatusService.documentSnapshot { coreStatus, error in
            if let error {
                Logger().error("[GPWCoreStatusViewModel] Unable to get to core version matrix changes: \(error.localizedDescription)")
                return
            }

            guard let coreStatus else {
                Logger().error("[GPWCoreStatusViewModel] Received no data")
                return
            }

            self.isLoading = false
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
            self.maintenanceMode = coreStatus.maintenanceMode
        }

        timeoutTimer = .scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
            DispatchQueue.main.async {
                self.hasTimedOut = true
                self.timeoutTimer = nil
            }
        }
    }

    func unsubscribe() {
        Logger().debug("[GPWCoreStatusViewModel] Unsubscribing")
        if let snapshotListner {
            snapshotListner.remove()
            self.snapshotListner = nil
        }
    }
}
