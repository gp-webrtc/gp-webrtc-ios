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
#endif
import Foundation

public struct GPWCKUser: GPWCKDocumentProtocol {
    public let id: String?
    public let userId: String
    public let displayName: String
    public let profilePicture: String?
    public let pinHash: String?
    public let settings: GPWCKUserSettings
    public let creationDate: Date?
    public let modificationDate: Date?

    init(from user: GPWCKEncryptedUser) throws {
        let decryptedData = user.isEncrypted
            ? GPWCKEncryptedUserData(displayName: "Encrypted Joe", profilePicture: nil)
            : try Self.base64Decode(encrypted: user.encrypted)

        id = user.id
        userId = user.userId
        displayName = decryptedData.displayName
        profilePicture = decryptedData.profilePicture
        settings = user.settings
        pinHash = user.pinHash
        creationDate = user.creationDate
        modificationDate = user.modificationDate
    }

    static func base64Decode(encrypted: String) throws -> GPWCKEncryptedUserData {
        guard let data = Data(base64Encoded: encrypted),
              let decryptedData = try? JSONDecoder().decode(GPWCKEncryptedUserData.self, from: data)
        else { throw GPWCKEncryptionError.unableToDecryptedData }

        return decryptedData
    }
}
