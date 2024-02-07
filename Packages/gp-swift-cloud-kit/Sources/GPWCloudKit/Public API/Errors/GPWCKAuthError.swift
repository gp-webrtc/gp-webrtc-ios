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

#if canImport(FirebaseAuth)
import FirebaseAuth
import Foundation

/// Describe errors generated by the Auth module.
///
/// See [Documentation](https://firebase.google.com/docs/auth/ios/errors)
public struct GPWCKAuthError: Error {
    public let code: AuthErrorCode.Code

    public init() {
        code = .internalError
    }

    public init(code: AuthErrorCode.Code) {
        self.code = code
    }

    public init(from error: Error) {
        code = AuthErrorCode.Code(rawValue: (error as NSError).code) ?? .internalError
    }

    public var localizedDescription: String {
        switch code {
            case .networkError:
                NSLocalizedString(
                    "Network error",
                    comment: "Network error"
                )
            case .userNotFound:
                NSLocalizedString(
                    "User not found",
                    comment: "User not found error"
                )
            case .userTokenExpired:
                NSLocalizedString(
                    "Session has expired",
                    comment: "Session has expired error"
                )
            case .tooManyRequests:
                NSLocalizedString(
                    "Too many requests, retry again after some time",
                    comment: "Too many requests, retry again after some time error"
                )
            case .invalidAPIKey:
                NSLocalizedString(
                    "Invalid API key",
                    comment: "Invalid API key error"
                )
            case .appNotAuthorized:
                NSLocalizedString(
                    "Application not authorized",
                    comment: "Application not authorized error"
                )
            case .keychainError:
                NSLocalizedString(
                    "Keychain could not be accessed",
                    comment: "Keychain could not be accessed error"
                )
            case .internalError:
                NSLocalizedString(
                    "Internal error",
                    comment: "Internal error"
                )
            case .operationNotAllowed:
                NSLocalizedString(
                    "Login method not allowed",
                    comment: "Login method not allowed error"
                )
            case .invalidEmail:
                NSLocalizedString(
                    "Invalid email",
                    comment: "Invalid email error"
                )
            case .wrongPassword:
                NSLocalizedString(
                    "Wrong password",
                    comment: "Wrong password error"
                )
            case .emailAlreadyInUse:
                NSLocalizedString(
                    "An acount already exists for this email, try loging in instead",
                    comment: "An acount already exists for this email error"
                )
            case .weakPassword:
                NSLocalizedString(
                    "Weak password",
                    comment: "Weak password error"
                )
            case .userDisabled:
                NSLocalizedString(
                    "User account disabled, contact support to re-enable it",
                    comment: "User account disabled error"
                )
            case .invalidCredential:
                NSLocalizedString(
                    "Invalid credentials",
                    comment: "Invalid credentials error"
                )
            case .userMismatch:
                NSLocalizedString(
                    "Session and user mismatched",
                    comment: "Session and user mismatched error"
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
