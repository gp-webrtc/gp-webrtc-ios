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
import UIKit
import UserNotifications

class GPWUserNotificationService {
    static var shared: GPWUserNotificationService {
        if let _instance { return _instance }
        else {
            _instance = GPWUserNotificationService()
            return _instance!
        }
    }

    private static var _instance: GPWUserNotificationService?

    private let cloudMessagingService = GPWCKCloudMessagingService.shared
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var isAuthorizedSubject = CurrentValueSubject<UNAuthorizationStatus?, Never>(nil)

    private init() {
        Task {
            do {
                let settings = await userNotificationCenter.notificationSettings()
                isAuthorizedSubject.send(settings.authorizationStatus)
                if settings.authorizationStatus == .authorized {
                    try await registerForRemoteNotifications()
                }
            } catch {
                Logger().error("[GPWUserNotificationService] Unable to register for remote notifications: \(error.localizedDescription)")
            }
        }
    }

    lazy var fcmRegistrationToken = cloudMessagingService.fcmRegistrationToken
    lazy var authorizationStatus = isAuthorizedSubject.eraseToAnyPublisher()

    var apnsToken: Data? {
        get { cloudMessagingService.apnsToken }
        set { cloudMessagingService.apnsToken = newValue }
    }

    func requestAuthorization() async throws -> Bool {
        let settings = await userNotificationCenter.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            Logger().debug("[GPWUserNotificationService] Request authorization for user notification")

            let isAuthorized = try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert])

            let settings = await userNotificationCenter.notificationSettings()
            isAuthorizedSubject.send(settings.authorizationStatus)

            if isAuthorized {
                try await registerForRemoteNotifications()
            }

            return isAuthorized
        } else {
            Logger().debug("[GPWUserNotificationService] Authorization have already been requested")
            return settings.authorizationStatus != .denied
        }
    }

    func registerForRemoteNotifications() async throws {
        let settings = await userNotificationCenter.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            await withCheckedContinuation { continuation in
                Logger().debug("[GPWUserNotificationService] Registering for remote notifications")
                DispatchQueue.main.async {
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

    func canHandleNotification(_ notification: [AnyHashable: Any]) -> Bool {
        if let messageId = notification["gcm.message_id"] as? String {
            Logger().debug("[GPWUserNotificationService] Message id: \(messageId)")
            cloudMessagingService.appDidReceiveMessage(notification)
            return true
        } else { return false }
    }
}
