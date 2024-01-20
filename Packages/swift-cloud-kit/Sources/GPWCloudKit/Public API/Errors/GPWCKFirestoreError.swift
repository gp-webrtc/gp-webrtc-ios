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

public enum GPWCKFirestoreError: Error {
    case firestore(error: Error)
    case `internal`
    case unableToReadData
    case unknown
}

extension GPWCKFirestoreError {
    init(from error: Error) {
        self = .firestore(error: error)
    }

    var isFatal: Bool { false }
}

extension GPWCKFirestoreError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .firestore(error: _):
                "Cloud Firestore error"
            case .internal:
                "Internal error"
            case .unableToReadData:
                "Unable to read data"
            case .unknown:
                "Unkown error"
        }
    }
}

extension GPWCKFirestoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case let .firestore(error: error):
                String(
                    format: NSLocalizedString(
                        "Cloud Firestore error '%s'",
                        comment: "Cloud Firestore error"
                    ),
                    error.localizedDescription
                )
            case .internal:
                NSLocalizedString(
                    "Internal error",
                    comment: "Internal error"
                )
            case .unableToReadData:
                NSLocalizedString(
                    "Unable to read data",
                    comment: "Unable to read data error"
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
