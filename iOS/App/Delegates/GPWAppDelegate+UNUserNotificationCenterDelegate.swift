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
import os.log
import UIKit
import UserNotifications

// MARK: - UNUserNotificationCenterDelegate

extension GPWAppDelegate: UNUserNotificationCenterDelegate {
    func configureUserNotifications() {
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

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Logger().debug("[GPWUserNotificationService] Will present push notification '\(notification.request.content.categoryIdentifier)'")

        // Get the user info from the original notification.
        let userInfo = notification.request.content.userInfo
        let categoryIdentifier = notification.request.content.categoryIdentifier

        Logger().debug("[GPWAppDelegate] User notification payload: \(userInfo)")

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
