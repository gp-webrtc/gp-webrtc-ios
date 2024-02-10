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
import GPWCloudKit
import os.log
import SwiftUI
import UserNotifications

class GPWUserNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static var shared: GPWUserNotificationService {
        if let _instance { return _instance }
        else {
            _instance = GPWUserNotificationService()
            return _instance!
        }
    }

    private static var _instance: GPWUserNotificationService?

    private let cloudMessagingService: GPWCKCloudMessagingService
    private let userNotificationCenter = UNUserNotificationCenter.current()

    override private init() {
        cloudMessagingService = GPWCKCloudMessagingService()
        super.init()

        userNotificationCenter.delegate = self

        Task {
            do {
                if try await requestAuthorization() {
                    try await registerForRemoteNotifications()
                }
            } catch {}
        }
    }

    var fcmRegistrationToken: AnyPublisher<String?, Never> { cloudMessagingService.fcmRegistrationToken }

    var apnsToken: Data? {
        get { cloudMessagingService.apnsToken }
        set { cloudMessagingService.apnsToken = newValue }
    }

    private func registerForRemoteNotifications() async throws {
        let settings = await userNotificationCenter.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    Logger().debug("[GPWUserNotificationService] Registering for remote notifications")
                    #if os(iOS)
                    UIApplication.shared.registerForRemoteNotifications()
                    #else
                    WKApplication.shared().registerForRemoteNotifications()
                    #endif
                    continuation.resume()
                }
            }
        } else {
            Logger().error("[GPWUserNotificationService] Unable to register for remote notifications: Not authorized (phone privacy settings)")
            throw GPWUserNotificationError.notAuthorized
        }
    }

    func requestAuthorization() async throws -> Bool {
        let settings = await userNotificationCenter.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            Logger().debug("[GPWUserNotificationService] Request authorization for user notification")
            return try await userNotificationCenter.requestAuthorization(options: [.provisional, .alert, .badge, .sound, .criticalAlert])
        } else {
            Logger().debug("[GPWUserNotificationService] Authorization have already been requested")
            return settings.authorizationStatus != .denied
        }
    }

    func canHandleNotification(_ notification: [AnyHashable: Any]) -> Bool {
        if let messageId = notification["gcm.message_id"] as? String {
            Logger().debug("[GPWUserNotificationService] Message id: \(messageId)")
            cloudMessagingService.appDidReceiveMessage(notification)
            return true
        } else { return false }
    }
}

// MARK: - Delegate methods

extension GPWUserNotificationService {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger().debug("[GPWUserNotificationService] Will present push notification \(notification.request.content.categoryIdentifier)")

        // Inform Cloud Messaging service
        cloudMessagingService.appDidReceiveMessage(notification.request.content.userInfo)
        completionHandler([])
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
                                @escaping () -> Void)
    {
        Logger().debug("[GPWUserNotificationService] Received push notification \(response.notification.request.content.categoryIdentifier)")

        // Get the meeting ID from the original notification.
        let userInfo = response.notification.request.content.userInfo

        // Inform Cloud Messaging service
        cloudMessagingService.appDidReceiveMessage(userInfo)

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

        // Always call the completion handler when done.
        completionHandler()
    }
}
