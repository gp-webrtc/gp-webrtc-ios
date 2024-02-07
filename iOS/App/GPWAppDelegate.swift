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

class GPWAppDelegate: NSObject, UIApplicationDelegate {
    let cloudAppService = GPWCKCloudAppService.shared

    // MARK: - App lifecycle

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        cloudAppService.configure(withConfiguration: .local)

        // If the intent is to connect to the emulator, uncomment the following
        // lines and comment the above one
        // BEGIN OF BLOCK
        //        cloudAppService.configure(
        //            withConfiguration: .local,
        //            usingEmulatorConfig: GPWCKEmulatorConfig(
        //                authEmulator: GPWCKEmulator(hostname: "gp-mac-studio.local.gpf.pw"),
        //                firestoreEmulator: GPWCKEmulator(hostname: "gp-mac-studio.local.gpf.pw"),
        //                functionsEmulator: GPWCKFunctionsEmulator(hostname: "gp-mac-studio.local.gpf.pw", region: "europe-west3"),
        //                storageEmulator: GPWCKEmulator(hostname: "gp-mac-studio.local.gpf.pw")
        //            )
        //        )
        // END OF BLOCK

        // All done
        return true
    }

    // MARK: - User notifications

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger().debug("[GPWAppDelegate] Device push notification token: \(deviceToken.reduce("") { $0 + String(format: "%02x", $1) })")
        GPWUserNotificationService.shared.apnsToken = deviceToken
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger().error("[GPWAppDelegate] Failed to register for remote notification: \(error)")
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Logger().debug("[GPWAppDelegate} Received remote notification: \(notification)")

        // Cloud notifications
        if GPWUserNotificationService.shared.canHandleNotification(notification) {
            Logger().debug("[GPWAppDelegate] Notification was handled by cloud notification layer")
            return completionHandler(.newData)
        }

        return completionHandler(.noData)
    }
}
