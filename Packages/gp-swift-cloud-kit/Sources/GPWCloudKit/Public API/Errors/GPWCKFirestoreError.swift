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

public enum GPWCKFirestoreError: Error {
    //    case firestore(error: Error)
    case `internal`
    case unableToGetDocument(path: String)
    case unableToGetCollectionDocuments(path: String)
    case unableToGetQueryDocuments(query: String)
    case unableToListenToDocumentChanges(path: String)
    case unableToListenToCollectionChanges(path: String)
    case unableToListenToQueryChanges(query: String)
    case unableToReadData(error: Error)
    case unknown
}

extension GPWCKFirestoreError {
    //    init(from error: Error) {
    //        self = .firestore(error: error)
    //    }

    var isFatal: Bool { false }
}

extension GPWCKFirestoreError: CustomStringConvertible {
    public var description: String {
        switch self {
            //            case .firestore(error: _):
            //                "Cloud Firestore error"
            case .internal:
                "Internal error"
            case let .unableToGetDocument(path: path):
                "Unable to get document at path \(path)"
            case let .unableToGetCollectionDocuments(path: path):
                "Unable to get documents of collection at path \(path)"
            case let .unableToGetQueryDocuments(query: query):
                "Unable to get documents for query \(query)"
            case let .unableToListenToDocumentChanges(path: path):
                "Unable to listen to changes on document at path \(path)"
            case let .unableToListenToCollectionChanges(path: path):
                "Unable to listen to changes on collection at path \(path)"
            case let .unableToListenToQueryChanges(query: query):
                "Unable to listen to changes on query \(query)"
            case let .unableToReadData(error: error):
                "Unable to read data (\(error.localizedDescription))"
            case .unknown:
                "Unkown error"
        }
    }
}

extension GPWCKFirestoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            //            case .firestore(let error):
            //                String.localizedStringWithFormat(
            //                    NSLocalizedString(
            //                        "Cloud Firestore error '%@'",
            //                        comment: "Cloud Firestore error"
            //                    ),
            //                    error.localizedDescription
            //                )
            case .internal:
                NSLocalizedString(
                    "Internal error",
                    comment: "Internal error"
                )
            case let .unableToGetDocument(path: path):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to get document at path %@",
                        comment: "Unable to get document at path error"
                    ),
                    path
                )
            case let .unableToGetCollectionDocuments(path: path):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to get documents of collection at path %@",
                        comment: "Unable to get documents of collection at path error"
                    ),
                    path
                )
            case let .unableToGetQueryDocuments(query: query):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to get documents for query %@",
                        comment: "Unable to get documents for query error"
                    ),
                    query
                )
            case let .unableToListenToDocumentChanges(path: path):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to listen to changes on document at path %@",
                        comment: "Unable to listen to changes on document at path error"
                    ),
                    path
                )
            case let .unableToListenToCollectionChanges(path: path):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to listen to changes on collection at path %@",
                        comment: "Unable to listen to changes on collection at path error"
                    ),
                    path
                )
            case let .unableToListenToQueryChanges(query: query):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to listen to changes on query %@",
                        comment: "Unable to listen to changes on query error"
                    ),
                    query
                )
            case let .unableToReadData(error: error):
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "Unable to read data (%@)",
                        comment: "Unable to read data error"
                    ),
                    error.localizedDescription
                )
            case .unknown:
                NSLocalizedString(
                    "Unknown error",
                    comment: "Unknown error"
                )
        }
    }
}
#endif
