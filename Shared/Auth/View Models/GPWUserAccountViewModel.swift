//
// gp-webrtc-ios
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

import Combine
import Foundation
import GPStorageKit
import GPWCloudKit
import os.log

@MainActor
final class GPWUserAccountViewModel: ObservableObject {
    @Published var userId: String?
    @Published var authState: GPWAuthState = .unknown

    private let authService = GPWCKAuthService.shared
    private let userService = GPWCKUserService.shared

    private var authStateDidChangeListener: GPWCKAuthStateDidChangeListener?
    private var idTokenDidChangeListener: GPWCKIDTokenDidChangeListener?

    func subscribe() {
        Logger().debug("[GPWUserAccountViewModel] Subscribing")
        if authStateDidChangeListener == nil {
            authStateDidChangeListener = authService.addStateDidChangeListener { userAccount in
                self.authState = userAccount != nil ? .signedIn : .signedOut
            }
        }
        if idTokenDidChangeListener == nil {
            idTokenDidChangeListener = authService.addIDTokenDidChangeListener { userAccount in
                self.userId = userAccount?.userId
                if let userId = userAccount?.userId, userId != GPSKStorageService.shared.userId {
                    GPSKStorageService.shared.userId = userId
                }
            }
        }
    }

    func unsubscribe() {
        Logger().debug("[GPWUserAccountViewModel] Unsubscribing")
        if let authStateDidChangeListener {
            authService.removeStateDidChangeListener(authStateDidChangeListener)
            self.authStateDidChangeListener = nil
        }
        if let idTokenDidChangeListener {
            authService.removeIDTokenDidChangeListener(idTokenDidChangeListener)
            self.idTokenDidChangeListener = nil
        }
    }

    func signInAnonymously() async throws {
        let userAccount = try await authService.signInAnonymously()
        try await userService.create(
            userAccount.userId,
            displayName: "John Doe",
            settings: GPWCKUserSettings()
        )
    }

    func delete() async throws {
        try await authService.deleteUser()
        GPSKStorageService.shared.resetUserData()
    }
}

extension GPWUserAccountViewModel {
    enum GPWAuthState {
        case unknown
        case signedIn
        case signedOut
    }
}
