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

import Combine
import Foundation
import GPWCloudKit
import os.log

@MainActor
class GPWCoreVersionViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var mustUpdateData = false
    @Published var mustUpdateApp = false
    @Published var modelVersion: String?
    @Published var targetIOSVersion: String?
    @Published var targetModelVersion: String?

    private let versionMatrixService = GPWCKCoreVersionMatrixService.shared

    private let versionMatrixSubject = CurrentValueSubject<GPWCKCoreVersionMatrix?, Never>(nil)

    private var snapshotListner: GPWCKSnapshotListener?
    private var cancellables = Set<AnyCancellable>()

    func subscribe(userId: String) {
        guard snapshotListner == nil else { return }

        snapshotListner = versionMatrixService.documentSnapshot(userId) { versionMatrix, error in
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
                self.versionMatrixSubject.send(versionMatrix)
            }
        }

        Publishers.CombineLatest3($isLoading, $modelVersion, versionMatrixSubject.eraseToAnyPublisher())
            .sink { isLoading, modelVersion, versionMatrix in
                guard !isLoading, let modelVersion, let versionMatrix else { return }

                // Get the app version
                guard let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String,
                      let version = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
                else {
                    Logger().error("[GPWCoreVersionViewModel] Unable to determine app version")
                    return
                }

                let appVersion = "\(shortVersion)(\(version))"

                // Is the app up to date
                if versionMatrix.minimalIOSVersion > appVersion {
                    self.mustUpdateApp = true
                    self.targetIOSVersion = versionMatrix.minimalIOSVersion
                    return
                }

                // Is the model up to date
                if versionMatrix.minimalModelVersion > modelVersion {
                    guard let modelVersionData = versionMatrix.model[versionMatrix.minimalModelVersion] else {
                        Logger().error("[GPWCoreVersionViewModel] Missing model version data for \(versionMatrix.minimalModelVersion)")
                        return
                    }

                    if !modelVersionData.supportedIOSVersions.contains(where: { $0 == appVersion }) {
                        self.mustUpdateApp = true
                        self.targetIOSVersion = versionMatrix.minimalIOSVersion
                        return
                    }
                }

                // Get the current iOS version data
                guard let currentIOSVersionData = versionMatrix.ios[appVersion] else {
                    Logger().error("[GPWCoreVersionViewModel] Missing iOS version data for \(appVersion)")
                    return
                }
                let maxSupportedModelVersion = currentIOSVersionData.supportedModelVersions.max()!

                if maxSupportedModelVersion > modelVersion {
                    self.mustUpdateData = true
                    self.targetModelVersion = maxSupportedModelVersion
                    return
                }

                // Reaching here means that nothing is required
                self.mustUpdateApp = false
                self.mustUpdateData = false
                self.targetModelVersion = nil
                self.targetIOSVersion = nil
            }
            .store(in: &cancellables)
    }

    func unsubscribe() {
        if let snapshotListner {
            snapshotListner.remove()
            self.snapshotListner = nil
        }

        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    func updateModel(to version: String, userId: String) async throws {
        try await versionMatrixService.updateModel(to: version, userId: userId)
    }
}
