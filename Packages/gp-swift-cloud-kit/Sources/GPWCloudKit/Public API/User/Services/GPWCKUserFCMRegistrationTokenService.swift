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

#if canImport(FirebaseFunctions)
import Foundation

public class GPWCKUserFCMRegistrationTokenService {
    public static var shared: GPWCKUserFCMRegistrationTokenService {
        if let _instance {
            return _instance
        } else {
            _instance = GPWCKUserFCMRegistrationTokenService()
            return _instance!
        }
    }

    private static var _instance: GPWCKUserFCMRegistrationTokenService?

    // MARK: - Cloud Firestore documents

    private let firestoreService = GPWCKFirestoreService<GPWCKEncryptedUser>()

    public func documentSnapshot(
        _ userId: String,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKUser>
    ) -> GPWCKSnapshotListener {
        let snapshotListener = firestoreService.documentSnapshotListener(
            .user(userId: userId)
        ) { encryptedUser, error in
            if let error {
                callback(nil, error)
                return
            }
            if let encryptedUser {
                do {
                    let user = try GPWCKUser(from: encryptedUser)
                    callback(user, nil)
                } catch {
                    callback(nil, error)
                }
                return
            } else {
                callback(nil, nil)
                return
            }
        }
        return snapshotListener
    }

    // MARK: - Cloud Functions

    public func insertOrUpdate(_ token: String, userId: String, tokenId: String) async throws {
        let insertOrUpdateFCMRegistrationTokenFunctionService = GPWCKFunctionService<GPWCKFunctionNoResponse>("user-insertOrUpdateFCMRegistrationToken", in: "europe-west3")
        try await insertOrUpdateFCMRegistrationTokenFunctionService
            .call(
                GPWCKUserFCMRegistrationTokenInsertionOrUpdateBody(
                    userId: userId,
                    tokenId: tokenId,
                    token: token,
                    deviceType: .iOSApp
                )
                .dictionary
            )
    }

    public func delete(_ tokenId: String, userId: String) async throws {
        let approvePendingFriendRequestFunctionService = GPWCKFunctionService<GPWCKFunctionNoResponse>("user-deleteFCMRegistrationToken", in: "europe-west1")
        try await approvePendingFriendRequestFunctionService
            .call(
                GPWCKUserFCMRegistrationTokenDeletionBody(
                    userId: userId,
                    tokenId: tokenId
                )
                .dictionary
            )
    }
}
#endif
