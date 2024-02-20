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

import Foundation
import GPWCloudKit
import os.log
import UIKit

extension GPWAppDelegate: UIApplicationDelegate {
    func configureCloudApp() {
        #if targetEnvironment(simulator)
        GPWCKCloudAppService.shared.configure(
            withConfiguration: .local,
            usingEmulatorConfig: GPWCKEmulatorConfig(
                authEmulator: GPWCKEmulator(hostname: "127.0.0.1"),
                firestoreEmulator: GPWCKEmulator(hostname: "127.0.0.1"),
                functionsEmulator: GPWCKFunctionsEmulator(hostname: "127.0.0.1", region: "europe-west3"),
                storageEmulator: GPWCKEmulator(hostname: "127.0.0.1")
            )
        )
        Task {
            do {
                try await GPWCKCoreService.shared.initEmulator()
            } catch {
                fatalError("[GPWAppDelegate] Unable to initialize emulator")
            }
        }
        #else
        GPWCKCloudAppService.shared.configure(withConfiguration: .local)
        #endif
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Cloud app
        configureCloudApp()

        // Configure user notifications
        configureUserNotifications()

        // Configure push kit
        configurePushKit()

        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Logger().debug("[GPWAppDelegate] APNS device token: \(deviceToken)")
        GPWUserNotificationService.shared.setAPNSToken(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger().error("[GPWAppDelegate] Failed to register for remote notification: \(error)")
        GPWUserNotificationService.shared.setAPNSToken(nil)
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Logger().debug("[GPWAppDelegate} Received remote notification: \(notification)")

        return completionHandler(.noData)
    }
}
