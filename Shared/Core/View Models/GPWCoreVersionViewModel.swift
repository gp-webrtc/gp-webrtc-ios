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

class GPWCoreVersionViewModel: Observable {
    @Published var isLoading = true
    @Published var showModelUpdate = false

    private let coreVersionMatrixService = GPWCKCoreVersionMatrixService.shared

    private var snapshotListner: GPWCKSnapshotListener?

    func subscribe(userId: String) {
        guard snapshotListner == nil else { return }

        snapshotListner = coreVersionMatrixService.documentSnapshot(userId) { versionMatrix, error in
            if let error {
                Logger().error("[GPWCoreVersionViewModel] Unable to subscribe to core version matrix changes: \(error.localizedDescription)")
                return
            }

            guard let versionMatrix else {
                Logger().error("[GPWCoreVersionViewModel] Received no data")
                return
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    func updateModel(to version: GPWCKCoreModelVersion, userId: String) async throws {
        try await coreVersionMatrixService.updateModel(to: version, userId: userId)
    }
}
