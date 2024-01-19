//
// gp-webrtc/swift-cloud-kit
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

/// Wraps the Firestore API to access user document ``GPWCKUser``
///
/// The user document can be read or updated, however it cannot be deleted. To do so, use
/// ``GPWCKAuthService/deleteUser(confirmationPassword:)``.
///
/// The user document holds the user public profile ``GPWCKUserPublicProfile``.
///
public struct GPWCKUserService {
    public static var shared: GPWCKUserService {
        if let instance {
            return instance
        } else {
            let instance = GPWCKUserService()
            GPWCKUserService.instance = instance
            return instance
        }
    }

    private static var instance: GPWCKUserService?

    private let firestoreService = GPWCKFirestoreService<GPWCKEncryptedUser>()

    public func documentSnapshot(
        _ userId: String,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKUser>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.documentSnapshotListener(.user(userId: userId)) { encryptedUser, error in
            if let encryptedUser {
                callback(
                    GPWCKUser(
                        id: encryptedUser.id,
                        userId: encryptedUser.userId,
                        displayName: "John Doe",
                        profilePicture: nil,
                        status: encryptedUser.status,
                        creationDate: encryptedUser.creationDate,
                        modificationDate: encryptedUser.modificationDate
                    ),
                    nil
                )
            } else {
                callback(nil, error)
            }
        }
        return snapshotListener
    }
}
#endif
