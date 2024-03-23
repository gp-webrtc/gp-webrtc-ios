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
import GPStorageKit
import GPWCloudKit
import os.log
import UIKit

@MainActor
final class GPWUserLocalDeviceViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var deviceId: String?
    @Published var displayName = ""
    @Published var isDeleted = false

    @GPSKPublishedUserDefault(\.userLocalDeviceId) private var userLocalDeviceId
    @GPSKPublishedUserDefault(\.isLocalDeviceRegistered) private var isLocalDeviceRegistered

    private let userDevicesSubject = CurrentValueSubject<[GPWCKUserDevice], Never>([])
    private let userDeviceService = GPWCKUserDeviceService.shared
    private var cancellables = Set<AnyCancellable>()
    private var snapshotListener: GPWCKSnapshotListener? = nil

    func subscribe(userId: String) {
        Logger().debug("[GPWUserLocalDeviceViewModel] Subscribing")
        isLoading = true
        guard snapshotListener == nil else { return }

        snapshotListener = userDeviceService.collectionSnapshot(userId) { userDevices, error in
            self.isLoading = false
            if let error {
                Logger().error("[GPWUserLocalDeviceViewModel] Unable to get user device list: \(error.localizedDescription)")
                return
            }
            self.userDevicesSubject.send(userDevices)
        }

        Publishers.CombineLatest4($isLoading, $userLocalDeviceId, userDevicesSubject.eraseToAnyPublisher(), $isLocalDeviceRegistered)
            .sink { isLoading, userLocalDeviceId, _, isLocalDeviceRegistered in
                guard !isLoading else { return }
                if userLocalDeviceId == nil {
                    Task {
                        do {
                            guard !isLocalDeviceRegistered else {
                                Logger().error("[GPWUserLocalDeviceViewModel] Unable to register this device: the device was already registered")
                                return
                            }
                            let userLocalDeviceId = UUID().uuidString
                            self.isLocalDeviceRegistered = true
                            self.userLocalDeviceId = userLocalDeviceId
                            try await self.create(userLocalDeviceId, userId: userId)
                        } catch {
                            Logger().error("[GPWUserLocalDeviceViewModel] Unable to register this device: \(error.localizedDescription)")
                        }
                    }
                } else {
                    self.isDeleted = true
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($userLocalDeviceId, userDevicesSubject.eraseToAnyPublisher())
            .sink { userLocalDeviceId, userDevices in
                if let userDevice = userDevices.first(where: { $0.deviceId == userLocalDeviceId }) {
                    self.deviceId = userDevice.deviceId
                    self.displayName = userDevice.displayName

                } else {
                    self.deviceId = nil
                    self.displayName = ""
                }
            }
            .store(in: &cancellables)
    }

    func unsubscribe() {
        Logger().debug("[GPWUserLocalDeviceViewModel] Unsubscribing")
        if let snapshotListener {
            snapshotListener.remove()
            self.snapshotListener = nil
        }
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    private func create(_ deviceId: String, userId: String) async throws {
        try await userDeviceService.create((userId, deviceId), displayName: UIDevice.current.name)
    }
}
