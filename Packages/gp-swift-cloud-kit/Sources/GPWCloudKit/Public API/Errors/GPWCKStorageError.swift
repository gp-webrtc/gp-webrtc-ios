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

#if canImport(FirebaseStorage)
import FirebaseStorage
import Foundation

public struct GPWCKStorageError: Error {
    public let code: StorageErrorCode

    public init() {
        code = .unknown
    }

    public init(from error: Error) {
        code = StorageErrorCode(rawValue: (error as NSError).code) ?? .unknown
    }

    public var localizedDescription: String {
        switch code {
            case .unknown:
                NSLocalizedString(
                    "An unknown error occurred",
                    comment: "An unknown error occurred"
                )
            case .bucketNotFound:
                NSLocalizedString(
                    "No object exists at the desired reference",
                    comment: "No object exists at the desired reference error"
                )
            case .objectNotFound:
                NSLocalizedString(
                    "Operation cancelled",
                    comment: "Operation cancelled error"
                )
            case .projectNotFound:
                NSLocalizedString(
                    "No project is configured for Cloud Storage",
                    comment: "No project is configured for Cloud Storage error"
                )
            case .quotaExceeded:
                NSLocalizedString(
                    "Quota exceeded, please contact support",
                    comment: "Quota exceeded error"
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
            case .unauthorized:
                NSLocalizedString(
                    "User is not authorized to perform the desired action",
                    comment: "User is not authorized to perform the desired action error"
                )
            case .retryLimitExceeded:
                NSLocalizedString(
                    "The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded",
                    comment: "The maximum time limit on an operation has been exceeded error"
                )
            case .nonMatchingChecksum:
                NSLocalizedString(
                    "File on the client does not match the checksum of the file recieved by the server",
                    comment: "File on the client does not match the checksum of the file recieved by the server error"
                )
            case .cancelled:
                NSLocalizedString(
                    "User canceled the operation",
                    comment: "User canceled the operation error"
                )
            case .downloadSizeExceeded:
                NSLocalizedString(
                    "Size of the downloaded file exceeds the amount of memory allocated for the download",
                    comment: "Size of the downloaded file exceeds the amount of memory allocated for the download error"
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
