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

#if canImport(FirebaseStorage)
import Foundation

/// This service allow to get path for file given a context (for example: the user profile image path)
enum GPWCKStorageFilePathService {
    // MARK: - User profile image

    /// Provide the full path of the user profile image given a `userId` and the `filename` of the image
    ///
    /// The user profile image filename is stored in the user profile (``GPWCKUser/publicProfile/profileImage``).
    ///
    /// - Parameters:
    ///     - userId: the id of the user
    ///     - filename: the filename of the image
    static func userProfileImage(userId: String, filename: String) -> String {
        "/users/\(userId)/profileImages/\(filename)"
    }

    /// Provide the full path of the user profile image thumbnail 32x32 given a `userId` and the `filename` of the image
    ///
    /// The user profile image filename is stored in the user profile (``GPWCKUser/publicProfile/profileImage``).
    ///
    /// - Parameters:
    ///     - userId: the id of the user
    ///     - filename: the filename of the image
    static func userProfileImage32Thumbnail(userId: String, filename: String) -> String {
        "/users/\(userId)/profileImages/thumbnails/32/\(filename)"
    }

    /// Provide the full path of the user profile image thumbnail 256x256 given a `userId` and the `filename` of the image
    ///
    /// The user profile image filename is stored in the user profile (``GPWCKUser/publicProfile/profileImage``).
    ///
    /// - Parameters:
    ///     - userId: the id of the user
    ///     - filename: the filename of the image

    static func userProfileImage256Thumbnail(userId: String, filename: String) -> String {
        "/users/\(userId)/profileImages/thumbnails/256/\(filename)"
    }
}
#endif
