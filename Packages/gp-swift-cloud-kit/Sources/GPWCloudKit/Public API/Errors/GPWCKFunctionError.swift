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

// TODO: Upgrade to new error management

#if canImport(FirebaseFunctions)
import FirebaseFunctions
import Foundation

public struct GPWCKFunctionError: Error {
    public let code: FunctionsErrorCode

    public init() {
        code = .unknown
    }

    public init(from error: Error) {
        code = FunctionsErrorCode(rawValue: (error as NSError).code) ?? .unknown
    }

    public var localizedDescription: String {
        switch code {
            case .unknown:
                NSLocalizedString(
                    "An unknown error occurred",
                    comment: "An unknown error occurred"
                )
            case .deadlineExceeded:
                NSLocalizedString(
                    "Deadline expired before operation could complete",
                    comment: "Deadline expired before operation could complete error"
                )
            case .notFound:
                NSLocalizedString(
                    "Some requested document was not found",
                    comment: "Some requested document was not found found"
                )
            case .alreadyExists:
                NSLocalizedString(
                    "Some document that we attempted to create already exists",
                    comment: "Some document that we attempted to create already exists error"
                )
            case .permissionDenied:
                NSLocalizedString(
                    "User is not authorized to perform the desired action",
                    comment: "User is not authorized to perform the desired action error"
                )
            case .unauthenticated:
                NSLocalizedString(
                    "User is unauthenticated",
                    comment: "User is unauthenticated error"
                )
            case .invalidArgument:
                NSLocalizedString(
                    "Invalid argument",
                    comment: "Invalid argument error"
                )
            case .resourceExhausted:
                NSLocalizedString(
                    "Some resource has been exhausted",
                    comment: "Some resource has been exhausted error"
                )
            case .failedPrecondition:
                NSLocalizedString(
                    "Operation was rejected because the system is not in a state required for the operation’s execution",
                    comment: "Operation was rejected because the system is not in a state required for the operation’s execution error"
                )
            case .aborted:
                NSLocalizedString(
                    "The operation was aborted",
                    comment: "The operation was aborted error"
                )
            case .cancelled:
                NSLocalizedString(
                    "User canceled the operation",
                    comment: "User canceled the operation error"
                )
            case .outOfRange:
                NSLocalizedString(
                    "Operation was attempted past the valid range",
                    comment: "Operation was attempted past the valid range error"
                )
            case .unavailable:
                NSLocalizedString(
                    "The service is currently unavailable",
                    comment: "The service is currently unavailable error"
                )
            case .dataLoss:
                NSLocalizedString(
                    "Unrecoverable data lost",
                    comment: "Unrecoverable data lost error"
                )
            case .unimplemented:
                NSLocalizedString(
                    "Operation not implemented or supported",
                    comment: "Operation not implemented or supported error"
                )
            default:
                NSLocalizedString(
                    "An unknown error occurred",
                    comment: "An unknown error occurred"
                )
        }
    }
}
#endif
