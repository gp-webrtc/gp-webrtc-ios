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

#if canImport(FirebaseFunctions)
import Combine
import FirebaseFunctions
import FirebaseSharedSwift
import Foundation

public class GPWCKFunctionService<GPWCKResponse: Codable> {
    let name: String
    let region: String

    public init(_ name: String, in region: String) {
        self.name = name
        self.region = region
    }
}

// When a response is expected
public extension GPWCKFunctionService where GPWCKResponse: GPWCKFunctionResponse {
    func call(_ body: some Codable) async throws -> GPWCKResponse? {
        let decoder = FirebaseDataDecoder()
        let result = try await Functions.functions(region: region).httpsCallable(name, responseAs: GPWCKResponse.self, decoder: decoder).call(body)

        return result
    }
}

// When no resposne is expected
public extension GPWCKFunctionService where GPWCKResponse == GPWCKFunctionNoResponse {
    func call(_ body: [String: Any]) async throws {
        let _ = try await Functions.functions(region: region).httpsCallable(name).call(body)
    }
}
#endif
