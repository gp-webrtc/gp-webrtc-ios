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
import FirebaseFirestore
import Foundation
import os.log

class GPWCKFirestoreService<GPWCKDocument: GPWCKDocumentProtocol> {
    let firestore = Firestore.firestore()

    init() {}

    func get(_ documentPath: GPWCKFirestoreDocumentPath) async throws -> GPWCKDocument? {
        let snapshot = try await documentPath.documentRef.getDocument()

        guard snapshot.exists else {
            return nil
        }

        let doc = try snapshot.data(as: GPWCKDocument.self)
        return doc
    }

    func getAll(_ collectionPath: GPWCKFirestoreCollectionPath) async throws -> [GPWCKDocument] {
        do {
            let snapshots = try await collectionPath.collectionRef.getDocuments()

            let docs = snapshots.documents.compactMap { doc -> GPWCKDocument?
                in try? doc.data(as: GPWCKDocument.self)
            }

            return docs
        } catch {
            throw GPWCKFirestoreError(from: error)
        }
    }

    func documentSnapshotListener(
        _ documentPath: GPWCKFirestoreDocumentPath,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKDocument>
    ) -> GPWCKSnapshotListener {
        documentPath.documentRef.addSnapshotListener { snapshot, error in
            if let error {
                callback(nil, GPWCKFirestoreError(from: error))
                return
            }

            // TODO: A specific error should be created when the snapshot is nil (internal error ?)
            guard let snapshot else {
                callback(nil, GPWCKFirestoreError())
                return
            }

            guard snapshot.exists else {
                callback(nil, nil)
                return
            }

            // TODO: A specific error should be created when the document cannot be posted
            guard let document = try? snapshot.data(as: GPWCKDocument.self) else {
                callback(nil, GPWCKFirestoreError())
                return
            }

            callback(document, nil)
        }
    }

    func collectionSnapshotListener(
        _ collectionPath: GPWCKFirestoreCollectionPath,
        onChanges callback: @escaping GPWCKQuerySnapshotChangesHandler<GPWCKDocument>
    ) -> GPWCKSnapshotListener {
        collectionPath.collectionRef.addSnapshotListener { snapshot, error in
            if let error {
                callback([], GPWCKFirestoreError(from: error))
                return
            }

            // TODO: A specific error should be created when the snapshot is nil (internal error ?)
            guard let snapshot else {
                callback([], GPWCKFirestoreError())
                return
            }

            let users = snapshot.documents.compactMap { document -> GPWCKDocument? in
                do {
                    let document = try document.data(as: GPWCKDocument.self)
                    return document
                } catch {
                    #if DEBUG
                    Logger().debug("Unable to parse data: \(error.localizedDescription)")
                    #endif
                    return nil
                }
            }

            callback(users, nil)
        }
    }

    func querySnapshotListener(
        _ query: Query,
        onChanges callback: @escaping GPWCKQuerySnapshotChangesHandler<GPWCKDocument>
    ) -> GPWCKSnapshotListener {
        query.addSnapshotListener { snapshot, error in
            if let error {
                callback([], GPWCKFirestoreError(from: error))
                return
            }

            // TODO: A specific error should be created when the snapshot is nil (internal error ?)
            guard let snapshot else {
                callback([], GPWCKFirestoreError())
                return
            }

            let users = snapshot.documents.compactMap { try? $0.data(as: GPWCKDocument.self) }

            callback(users, nil)
        }
    }

    func removeListener(_ listener: GPWCKSnapshotListener) {
        listener.remove()
    }

    // MARK: - Create

    func create(_ data: GPWCKDocument, atPath collectionPath: GPWCKFirestoreCollectionPath) async throws {
        _ = try collectionPath.collectionRef.addDocument(from: data)
    }

    func create(_ data: GPWCKDocument, atPath documentPath: GPWCKFirestoreDocumentPath) async throws {
        try documentPath.documentRef.setData(from: data)
    }

    // MARK: - Update

    func update(from data: GPWCKDocument, atPath documentPath: GPWCKFirestoreDocumentPath) async throws {
        try documentPath.documentRef.setData(from: data)
    }

    func update(from data: some GPWCKDataProtocol, atPath documentPath: GPWCKFirestoreDocumentPath) async throws {
        try documentPath.documentRef.setData(from: data, merge: true)
    }

    // MARK: - Delete

    func delete(_ documentPath: GPWCKFirestoreDocumentPath) async throws {
        try await documentPath.documentRef.delete()
    }
}
#endif
