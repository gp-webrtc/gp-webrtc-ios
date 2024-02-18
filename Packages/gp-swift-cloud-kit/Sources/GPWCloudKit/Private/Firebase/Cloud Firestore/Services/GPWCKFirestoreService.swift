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
import os.log

class GPWCKFirestoreService<GPWCKDocument: GPWCKDocumentProtocol> {
    let firestore = Firestore.firestore()

    init() {}

    func get(_ documentPath: GPWCKFirestoreDocumentPath) async throws -> GPWCKDocument? {
        do {
            let document = try await documentPath.documentRef.getDocument()

            guard document.exists else {
                return nil
            }

            let doc = try document.data(as: GPWCKDocument.self)
            return doc
        } catch {
            throw GPWCKFirestoreError.unableToGetDocument(path: documentPath.string)
        }
    }

    func getAll(_ collectionPath: GPWCKFirestoreCollectionPath) async throws -> [GPWCKDocument] {
        do {
            let documents = try await collectionPath.collectionRef.getDocuments()

            let docs = documents.documents.compactMap { doc -> GPWCKDocument?
                in try? doc.data(as: GPWCKDocument.self)
            }

            return docs
        } catch {
            throw GPWCKFirestoreError.unableToGetCollectionDocuments(path: collectionPath.string)
        }
    }

    func getSome(_ query: Query) async throws -> [GPWCKDocument] {
        do {
            let query = try await query.getDocuments()

            let docs = query.documents.compactMap { doc -> GPWCKDocument?
                in try? doc.data(as: GPWCKDocument.self)
            }

            return docs
        } catch {
            throw GPWCKFirestoreError.unableToGetQueryDocuments(query: query.debugDescription)
        }
    }

    func documentSnapshotListener(
        _ documentPath: GPWCKFirestoreDocumentPath,
        onChanges callback: @escaping GPWCKDocumentSnapshotChangesHandler<GPWCKDocument>
    ) -> GPWCKSnapshotListener {
        documentPath.documentRef.addSnapshotListener { snapshot, error in
            if let error {
                Logger().error("[GPWCKFirestoreService] Unable to listen to document snapshort due to Firestore error: \(error.localizedDescription)")
                callback(nil, GPWCKFirestoreError.unableToListenToDocumentChanges(path: documentPath.string))
                return
            }

            guard let snapshot else {
                callback(nil, nil)
                return
            }

            guard snapshot.exists else {
                callback(nil, nil)
                return
            }

            do {
                let document = try snapshot.data(as: GPWCKDocument.self)
                callback(document, nil)
            } catch {
                callback(nil, GPWCKFirestoreError.unableToReadData(error: error))
            }
        }
    }

    func collectionSnapshotListener(
        _ collectionPath: GPWCKFirestoreCollectionPath,
        onChanges callback: @escaping GPWCKQuerySnapshotChangesHandler<GPWCKDocument>
    ) -> GPWCKSnapshotListener {
        collectionPath.collectionRef.addSnapshotListener { snapshot, error in
            if let error {
                Logger().error("[GPWCKFirestoreService] Unable to listen to collection snapshort due to Firestore error: \(error.localizedDescription)")
                callback([], GPWCKFirestoreError.unableToListenToCollectionChanges(path: collectionPath.string))
                return
            }

            guard let snapshot else {
                callback([], nil)
                return
            }

            let users = snapshot.documents.compactMap { document -> GPWCKDocument? in
                do {
                    let document = try document.data(as: GPWCKDocument.self)
                    return document
                } catch {
                    Logger().debug("[GPWCKFirestoreService] Unable to parse document \(document.reference.path)/\(document.reference.documentID): \(error.localizedDescription)")
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
                Logger().error("[GPWCKFirestoreService] Unable to listen to query snapshort due to Firestore error: \(error.localizedDescription)")
                callback([], GPWCKFirestoreError.unableToListenToQueryChanges(query: query.debugDescription))
                return
            }

            // TODO: A specific error should be created when the snapshot is nil (internal error ?)
            guard let snapshot else {
                callback([], nil)
                return
            }

            let users = snapshot.documents.compactMap { document in
                do {
                    let document = try document.data(as: GPWCKDocument.self)
                    return document
                } catch {
                    Logger().debug("[GPWCKFirestoreService] Unable to parse document \(document.reference.path)/\(document.reference.documentID): \(error.localizedDescription)")
                    return nil
                }
            }

            callback(users, nil)
        }
    }

    func removeListener(_ authStateDidChangeListener: GPWCKSnapshotListener) {
        authStateDidChangeListener.remove()
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
