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

public enum GPWCKCoreIOSVersion: String, GPWCKDataProtocol {
    case v0_0_0_0 = "0.0.0(0)"
    case v0_1_0_1 = "0.1.0(1)"
}

public enum GPWCKCoreModelVersion: String, GPWCKDataProtocol {
    case v0_0_0_0 = "0.0.0(0)"
    case v0_1_0_1 = "0.1.0(1)"
}

public struct GPWCKModelUpgradeChain: GPWCKDataProtocol {
    let upgradableFrom: GPWCKCoreModelVersion
    let supportedIOSVersions: [GPWCKCoreIOSVersion]
}

public struct GPWCKCoreIOSSupportedModel: GPWCKDataProtocol {
    let supportedModelVersions: [GPWCKCoreModelVersion]
}

public struct GPWCKCoreVersionMatrix: GPWCKDocumentProtocol {
    #if canImport(FirebaseFirestore)
    @DocumentID public var id: String?
    #else
    public var id: String?
    #endif

    let minimalIOSVersion: GPWCKCoreIOSVersion
    let minimalCoreModel: GPWCKCoreModelVersion
    let model: [GPWCKCoreModelVersion: GPWCKModelUpgradeChain]
    let ios: [GPWCKCoreIOSVersion: GPWCKCoreIOSSupportedModel]

    #if canImport(FirebaseFirestore)
    @ServerTimestamp public var creationDate: Date?
    @ServerTimestamp public var modificationDate: Date?
    #else
    public var creationDate: Date?
    public var modificationDate: Date?
    #endif
}
