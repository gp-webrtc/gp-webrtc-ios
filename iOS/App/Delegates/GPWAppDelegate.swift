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
import PushKit
import UIKit
import UserNotifications

class GPWAppDelegate: NSObject {
    private var voipRegistry = PKPushRegistry(queue: nil)
//    private let voipQueue = DispatchQueue(label: "voip")

    override init() {
        super.init()
    }

    private func configureCloudApp() {
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
        #if GPW_DEVELOPMENT
        GPWCKCloudAppService.shared.configure(withConfiguration: .local)
        #endif
        #if GPW_RELEASE
        GPWCKCloudAppService.shared.configure(withConfiguration: .release)
        #endif
        #endif
    }

    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()

        // Check is authorized
        Task {
            do {
                let _ = try await GPWUserNotificationService.shared.requestAuthorization()
            } catch {
                Logger().error("[GPWAppDelegate] Unable to request authorizations")
            }
        }
    }

    private func configurePushKit() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
}

// MARK: - UIApplicationDelegate

extension GPWAppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure push kit
        configurePushKit()

        // Configure user notifications
        configureUserNotifications()

        // Configure Cloud app
        configureCloudApp()

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

// MARK: - UNUserNotificationCenterDelegate

extension GPWAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Logger().debug("[GPWAppDelegate] Will present push notification '\(notification.request.content.categoryIdentifier)'")

        // Get the user info from the original notification.
        let categoryIdentifier = notification.request.content.categoryIdentifier

        // Check the message type
        switch categoryIdentifier {
            case "USER_DEVICE_ADDED":
                return [.banner, .badge, .sound, .list]
            default:
                Logger().warning("[GPWAppDelegate] Received unhandled pushed notification '\(notification.request.content.categoryIdentifier)'")
                return []
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        Logger().debug("[GPWAppDelegate] Received push notification \(response.notification.request.content.categoryIdentifier)")

        // Get the user info from the original notification.
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier

        // Check the message type
        switch categoryIdentifier {
            case "USER_DEVICE_ADDED":
                guard let deviceId = userInfo["deviceId"] as? String else {
                    Logger().error("[GPWAppDelegate] USER_DEVICE_ADDED - Missing deviceId field")
                    return
                }
                processDeviceAddedNotification(deviceId)
                return
            default:
                Logger().warning("[GPWAppDelegate] Received unhandled pushed notification '\(response.notification.request.content.categoryIdentifier)'")
                return
        }
    }

    private func processDeviceAddedNotification(_ deviceId: String) {
        Logger().debug("[GPWAppDelegate] Processing device \(deviceId)")
    }
}

// MARK: - PKPushRegistryDelegate

extension GPWAppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == .voIP {
            let deviceToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
            Logger().debug("[GPWAppDelegate] PushKit VoIP device token: \(deviceToken)")
            GPWUserNotificationService.shared.setVOIPToken(deviceToken)
        }
    }

    func pushRegistry(_: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        if type == .voIP {
            Logger().debug("[GPWAppDelegate] Invalidated VoIP push credentials")
            GPWUserNotificationService.shared.setVOIPToken(nil)
        }
    }

    func pushRegistry(_: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) async {
        if type == .voIP {
            await GPWCallManagerService.shared.processIncomingCall(with: payload)

//            if let callerId = payload.dictionaryPayload["callerId"] as? String,
//               let callId = payload.dictionaryPayload["callId"] as? String,
//               let callId = UUID(uuidString: callId),
//               let displayName = payload.dictionaryPayload["displayName"] as? String
//            {
//                Logger().debug("[GPWAppDelegate] Reporting incoming call \(callId.uuidString)")
//                await GPWCallManagerService.shared.processIncommingCall(
//                    with: callId,
//                    callerId: callerId,
//                    displayName: displayName
//                )
//            } else {
//                Logger().debug("[GPWAppDelegate] Reporting incoming unidentified call as fake")
//                await GPWCallManagerService.shared.reportFakeCall()
//            }
        }
    }
}
