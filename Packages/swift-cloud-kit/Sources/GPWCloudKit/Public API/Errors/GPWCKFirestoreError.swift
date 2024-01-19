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

// TODO: Upgrade to new error management

#if canImport(FirebaseFirestore)
import FirebaseFirestore
import Foundation

public struct GPWCKFirestoreError: Error {
    public let code: FirestoreErrorCode.Code

    public init(_ code: FirestoreErrorCode.Code = .internal) {
        self.code = code
    }

    public init(from error: Error) {
        code = FirestoreErrorCode.Code(rawValue: (error as NSError).code) ?? .internal
    }

    public var localizedDescription: String {
        switch code {
            case .aborted:
                NSLocalizedString(
                    "Operation aborted",
                    comment: "Operation aborted error"
                )
            case .alreadyExists:
                NSLocalizedString(
                    "A document already exists",
                    comment: "A document already exists error"
                )
            case .cancelled:
                NSLocalizedString(
                    "Operation cancelled",
                    comment: "Operation cancelled error"
                )
            case .dataLoss:
                NSLocalizedString(
                    "Unrecoverable data lost",
                    comment: "Unrecoverable data lost error"
                )
            case .failedPrecondition:
                NSLocalizedString(
                    "Wrong state",
                    comment: "Wrong state error"
                )
            case .internal:
                NSLocalizedString(
                    "Internal error",
                    comment: "Internal error"
                )
            case .invalidArgument:
                NSLocalizedString(
                    "Invalid argument",
                    comment: "Invalid argument error"
                )
            case .notFound:
                NSLocalizedString(
                    "Document not found",
                    comment: "Document not found error"
                )
            case .outOfRange:
                NSLocalizedString(
                    "Out of range",
                    comment: "Out of range error"
                )
            case .permissionDenied:
                NSLocalizedString(
                    "Permission denied",
                    comment: "Permission denied error"
                )
            case .resourceExhausted:
                NSLocalizedString(
                    "Quota reached",
                    comment: "Quota reached error"
                )
            case .unauthenticated:
                NSLocalizedString(
                    "Not authenticated",
                    comment: "Not authenticated error"
                )
            case .unimplemented:
                NSLocalizedString(
                    "Operation not implemented or supported",
                    comment: "Operation not implemented or supported error"
                )
            default:
                NSLocalizedString(
                    "Unknown error",
                    comment: "Unknown error"
                )
        }
    }
}
#endif
