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
import FirebaseSharedSwift
import Foundation

public struct GPWCKUserNotificationService {
    public static var shared: GPWCKUserNotificationService {
        if let _instance {
            return _instance
        } else {
            _instance = GPWCKUserNotificationService()
            return _instance!
        }
    }

    private static var _instance: GPWCKUserNotificationService?

    private let firestoreService = GPWCKFirestoreService<GPWCKUserNotification>()

    public func documentSnapshot(
        _ deviceId: String,
        of userId: String,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKUserNotification>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.documentSnapshotListener(
            .userDevice(userId: userId, deviceId: deviceId)
        ) { userNotification, error in
            if let error {
                callback(nil, error)
                return
            } else {
                if let userNotification {
                    callback(userNotification, nil)
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
        onChanges callback: @escaping GPWCKQuerySnapshotChangesHandler<GPWCKUserNotification>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.collectionSnapshotListener(
            .userDeviceList(userId: userId)
        ) { userNotifications, error in
            if let error {
                callback([], error)
                return
            }

            callback(userNotifications, nil)
        }
        return snapshotListener
    }
}
#endif
