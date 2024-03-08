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

//public enum GPWCKCoreIOSVersion: String, GPWCKDataProtocol, Comparable {
//    case v0_0_0 = "0"
//    case v0_1_0 = "0.1.0"
//
//    public static func < (lhs: GPWCKCoreIOSVersion, rhs: GPWCKCoreIOSVersion) -> Bool {
//        lhs.rawValue < rhs.rawValue
//    }
//}

public enum GPWCKCoreModelVersion: String, GPWCKDataProtocol, Comparable {
    case v0 = "0.0.0"
    case v1 = "0.1.0"

    public static func < (lhs: GPWCKCoreModelVersion, rhs: GPWCKCoreModelVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct GPWCKModelUpgradeChain: GPWCKDataProtocol {
    public let upgradableFrom: String
    public let supportedIOSVersions: [String]
}

public struct GPWCKCoreIOSSupportedModel: GPWCKDataProtocol {
    public let supportedModelVersions: [String]
}

public struct GPWCKCoreVersion: GPWCKDocumentProtocol {
    #if canImport(FirebaseFirestore)
    @DocumentID public var id: String?
    #else
    public var id: String?
    #endif

    public let minimalIOSVersion: String
    public let minimalModelVersion: String
    public let model: [String: GPWCKModelUpgradeChain]
    public let ios: [String: GPWCKCoreIOSSupportedModel]

    #if canImport(FirebaseFirestore)
    @ServerTimestamp public var creationDate: Date?
    @ServerTimestamp public var modificationDate: Date?
    #else
    public var creationDate: Date?
    public var modificationDate: Date?
    #endif
}
