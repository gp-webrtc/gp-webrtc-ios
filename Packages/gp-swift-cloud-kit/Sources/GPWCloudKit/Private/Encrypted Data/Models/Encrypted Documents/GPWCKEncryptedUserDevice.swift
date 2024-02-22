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

struct GPWCKEncryptedUserDevice: GPWCKDocumentProtocol {
    #if canImport(FirebaseFirestore)
    @DocumentID public var id: String?
    #else
    var id: String?
    #endif

    let userId: String
    let deviceId: String
    let isEncrypted: Bool
    let encrypted: String

    #if canImport(FirebaseFirestore)
    @ServerTimestamp var creationDate: Date?
    @ServerTimestamp var modificationDate: Date?
    #else
    let creationDate: Date?
    let modificationDate: Date?
    #endif

    init(from userDevice: GPWCKUserDevice) throws {
        let encryptedData = GPWCKEncryptedUserDeviceData(
            displayName: userDevice.displayName
        )

        guard let encrypted = try? JSONEncoder().encode(encryptedData).base64EncodedString()
        else { throw GPWCKEncryptionError.unableToEncryptData }

        id = userDevice.id
        userId = userDevice.userId
        deviceId = userDevice.deviceId
        isEncrypted = false
        self.encrypted = encrypted
        creationDate = userDevice.creationDate
        modificationDate = userDevice.modificationDate
    }
}
