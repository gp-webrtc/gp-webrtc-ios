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

public class GPWCKAuthService {
    public typealias GPWCKAuthStateDidChangeBlock = (GPWCKUserAccount?) -> Void
    public typealias GPWCKIDTokenDidChangeBlock = (GPWCKUserAccount?) -> Void

    public static var shared: GPWCKAuthService {
        if let instance {
            return instance
        } else {
            let instance = GPWCKAuthService()
            GPWCKAuthService.instance = instance
            return instance
        }
    }

    private static var instance: GPWCKAuthService?

    private let auth = Auth.auth()

    public var currentUser: GPWCKUserAccount? {
        guard let user = auth.currentUser else { return nil }
        return try? GPWCKUserAccount(from: user)
    }

    public func addStateDidChangeListener(onChanges callback: @escaping GPWCKAuthStateDidChangeBlock = { _ in }) -> GPWCKAuthStateDidChangeListener {
        auth.addStateDidChangeListener { _, user in
            if let user {
                if let currentUser = self.auth.currentUser {
                    currentUser.getIDTokenResult(forcingRefresh: true) { _, error in
                        if error != nil {
                            Task { try? await currentUser.delete() }
                            callback(nil)
                        }
                    }
                }
                if let user = try? GPWCKUserAccount(from: user) {
                    callback(user)
                    return
                }
            }

            callback(nil)
        }
    }

    public func removeStateDidChangeListener(_ authStateDidChangeListener: GPWCKIDTokenDidChangeListener) {
        auth.removeStateDidChangeListener(authStateDidChangeListener)
    }

    public func addIDTokenDidChangeListener(onChanges callback: @escaping GPWCKIDTokenDidChangeBlock = { _ in }) -> GPWCKIDTokenDidChangeListener {
        auth.addIDTokenDidChangeListener { _, user in
            if let user {
                if let user = try? GPWCKUserAccount(from: user) {
                    callback(user)
                    return
                }
            }

            callback(nil)
        }
    }

    public func removeIDTokenDidChangeListener(_ authStateDidChangeListener: GPWCKIDTokenDidChangeListener) {
        auth.removeIDTokenDidChangeListener(authStateDidChangeListener)
    }

    public func idTokenForcingRefresh(_ forceRefresh: Bool) async throws -> String? {
        guard let user = auth.currentUser else { return nil }
        return try await user.idTokenForcingRefresh(forceRefresh)
    }

    public func getIdToken(forcingRefresh forceRefresh: Bool) async throws {
        if let user = auth.currentUser {
            try await user.getIDTokenResult(forcingRefresh: forceRefresh)
        }
    }

    public func reload() async throws {
        if let user = auth.currentUser {
            try await user.reload()
        }
    }

    #if !os(watchOS)

    public func signInAnonymously() async throws -> GPWCKUserAccount {
        guard auth.currentUser == nil else {
            throw GPWCKAuthError(code: .credentialAlreadyInUse)
        }
        let result = try await auth.signInAnonymously()
        return try GPWCKUserAccount(from: result.user)
    }

    public func deleteUser() async throws {
        if let user = auth.currentUser {
            try await user.delete()
        } else {
            throw GPWCKAuthError(code: .userNotFound)
        }
    }

    #endif
}
#endif
