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
import os.log
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

    private let userNotificationCenter = UNUserNotificationCenter.current()

    private var apnsTokenSubject = CurrentValueSubject<String?, Never>(nil)
    private var voipTokenSubject = CurrentValueSubject<String?, Never>(nil)
    private var isAuthorizedSubject = CurrentValueSubject<UNAuthorizationStatus?, Never>(nil)

    private init() {
        Task {
            let settings = await userNotificationCenter.notificationSettings()
            isAuthorizedSubject.send(settings.authorizationStatus)
        }
    }

    lazy var authorizationStatus = isAuthorizedSubject.eraseToAnyPublisher()
    lazy var apnsToken = apnsTokenSubject.eraseToAnyPublisher()
    lazy var voipToken = voipTokenSubject.eraseToAnyPublisher()

    func setAPNSToken(_ token: String?) {
        apnsTokenSubject.send(token)
    }

    func setVOIPToken(_ token: String?) {
        voipTokenSubject.send(token)
    }

    func requestAuthorization() async throws -> Bool {
        let settings = await userNotificationCenter.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            Logger().debug("[GPWUserNotificationService] Request authorization for user notification")

            let isAuthorized = try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert])

            let settings = await userNotificationCenter.notificationSettings()
            isAuthorizedSubject.send(settings.authorizationStatus)

            return isAuthorized
        } else {
            Logger().debug("[GPWUserNotificationService] Authorization have already been requested")
            return settings.authorizationStatus != .denied
        }
    }
}
