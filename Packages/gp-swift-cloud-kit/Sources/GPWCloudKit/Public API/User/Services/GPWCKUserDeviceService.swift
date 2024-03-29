//
// gp-webrtc-ios/swift-cloud-kit
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

#if canImport(FirebaseFirestore)
import FirebaseFirestore
import Foundation

public struct GPWCKUserDeviceService {
    public static var shared: GPWCKUserDeviceService {
        if let instance {
            return instance
        } else {
            let instance = GPWCKUserDeviceService()
            GPWCKUserDeviceService.instance = instance
            return instance
        }
    }

    private static var instance: GPWCKUserDeviceService?

    private let firestoreService = GPWCKFirestoreService<GPWCKEncryptedUserDevice>()

    public func documentSnapshot(
        _ deviceId: String,
        of userId: String,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKUserDevice>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.documentSnapshotListener(
            .userDevice(userId: userId, deviceId: deviceId)
        ) { encryptedUserDevice, error in
            if let error {
                callback(nil, error)
                return
            } else {
                if let encryptedUserDevice {
                    do {
                        let userDevice = try GPWCKUserDevice(from: encryptedUserDevice)
                        callback(userDevice, nil)
                    } catch {
                        callback(nil, error)
                    }
                    return
                } else {
                    callback(nil, nil)
                    return
                }
            }
        }
        return snapshotListener
    }

    public func collectionSnapshot(
        _ userId: String,
        onChanges callback: @escaping GPWCKQuerySnapshotChangesHandler<GPWCKUserDevice>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.collectionSnapshotListener(
            .userDeviceList(userId: userId)
        ) { encryptedUserDevices, error in
            if let error {
                callback([], error)
                return
            }

            let userDeviceList = encryptedUserDevices.compactMap { encryptedUserDevice -> GPWCKUserDevice? in
                try? GPWCKUserDevice(from: encryptedUserDevice)
            }
            callback(userDeviceList, nil)
        }
        return snapshotListener
    }

    public func create(_ key: (userId: String, deviceId: String), displayName: String) async throws {
        let encryptedUserDevice = try GPWCKEncryptedUserDevice(
            from: GPWCKUserDevice(
                userId: key.userId,
                deviceId: key.deviceId,
                displayName: displayName
            )
        )
        try await firestoreService.create(
            encryptedUserDevice,
            atPath: .userDevice(userId: key.userId, deviceId: key.deviceId)
        )
    }

    public func delete(_ deviceId: String, of userId: String) async throws {
        try await firestoreService.delete(.userDevice(userId: userId, deviceId: deviceId))
    }
}
#endif
