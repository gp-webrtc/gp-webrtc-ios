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

class GPWAppDelegate: NSObject, UIApplicationDelegate {
    private func configureCloudApp() {
        // #if targetEnvironment(simulator)
        //        cloudAppService.configure(
        //            withConfiguration: .local,
        //            usingEmulatorConfig: GPWCKEmulatorConfig(
        //                authEmulator: GPWCKEmulator(hostname: "127.0.0.1"),
        //                firestoreEmulator: GPWCKEmulator(hostname: "127.0.0.1"),
        //                functionsEmulator: GPWCKFunctionsEmulator(hostname: "127.0.0.1", region: "europe-west3"),
        //                storageEmulator: GPWCKEmulator(hostname: "127.0.0.1")
        //            )
        //        )
        // #else
        GPWCKCloudAppService.shared.configure(withConfiguration: .local)
        // #endif
    }

    // MARK: - UIApplicationDelegate

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureCloudApp()
        configureUserNotifications()
        configureVoIP()

        return true
    }

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

// MARK: - UNUserNotificationCenterDelegate

extension GPWAppDelegate: UNUserNotificationCenterDelegate {
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Logger().debug("[GPWUserNotificationService] Will present push notification '\(notification.request.content.categoryIdentifier)'")

        // Get the user info from the original notification.
        let userInfo = notification.request.content.userInfo
        let categoryIdentifier = notification.request.content.categoryIdentifier

        Logger().debug("[GPWAppDelegate] User notification payload: \(notification.request.content.userInfo)")

        // Inform Cloud Messaging service
        GPWCKCloudMessagingService.shared.appDidReceiveMessage(userInfo)

        // Check the message type
        switch categoryIdentifier {
            case "USER_DEVICE_ADDED":
                return [.banner, .badge, .sound, .list]
            default:
                Logger().warning("[GPWUserNotificationService] Received unhandled pushed notification '\(notification.request.content.categoryIdentifier)'")
                return []
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        Logger().debug("[GPWUserNotificationService] Received push notification \(response.notification.request.content.categoryIdentifier)")

        // Get the user info from the original notification.
        let userInfo = response.notification.request.content.userInfo

        Logger().debug("[GPWAppDelegate] User notification payload: \(response.notification.request.content.userInfo)")

        // Inform Cloud Messaging service
        GPWCKCloudMessagingService.shared.appDidReceiveMessage(userInfo)

        switch response.notification.request.content.categoryIdentifier {
            case "USER_DEVICE_ADDED":
                processDeviceAddedNotification(userInfo)
            default:
                Logger().warning("[GPWUserNotificationService] Received unhandled pushed notification '\(response.notification.request.content.categoryIdentifier)'")
        }
        if response.notification.request.content.categoryIdentifier == "USER_CALL_REQUEST" {
            // Retrieve the meeting details.
            let callerId = userInfo["callerId"] as! String

            Logger().debug("[GPWUserNotificationService] Received push notification USER_CALL_REQUEST with user id = \(callerId)")

            //            switch response.actionIdentifier {
            //                case "ACCEPT_ACTION":
            //                    sharedMeetingManager.acceptMeeting(user: userID,
            //                                                       meetingID: meetingID)
            //                    break
            //
            //                case "DECLINE_ACTION":
            //                    sharedMeetingManager.declineMeeting(user: userID,
            //                                                        meetingID: meetingID)
            //                    break
            //
            //                case UNNotificationDefaultActionIdentifier,
            //                UNNotificationDismissActionIdentifier:
            //                    // Queue meeting-related notifications for later
            //                    //  if the user does not act.
            //                    sharedMeetingManager.queueMeetingForDelivery(user: userID,
            //                                                                 meetingID: meetingID)
            //                    break
            //
            //                default:
            //                    break
            //            }
        } else {
            Logger().warning("[GPWUserNotificationService] Received unhandled pushed notification '\(response.notification.request.content.categoryIdentifier)'")
        }
    }

    private func processDeviceAddedNotification(_ userInfo: [AnyHashable: Any]) {
        Logger().debug("[GPWUserNotificationService] Received push notification DEVICE_ADDED with user info = \(userInfo)")
    }

    private func processDeviceRemovedNotification(_ userInfo: [AnyHashable: Any]) {
        Logger().debug("[GPWUserNotificationService] Received push notification DEVICE_REMOVED with user info = \(userInfo)")
    }
}

// MARK: - PKPushRegistryDelegate

extension GPWAppDelegate: PKPushRegistryDelegate {
    private func configureVoIP() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    func pushRegistry(_: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        Logger().debug("[GPWAppDelegate] Received VoIP push credentials \(pushCredentials.description)")
    }

    func pushRegistry(_: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard type == .voIP else { return }
        Logger().debug("[GPWAppDelegate] Invalidated VoIP push credentials")
    }

    func pushRegistry(_: PKPushRegistry, didReceiveIncomingPushWith _: PKPushPayload, for type: PKPushType) async {
        guard type == .voIP else { return }
        Logger().debug("[GPWAppDelegate] Received incomming VoIP push")
    }
}
