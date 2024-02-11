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

import GPWCloudKit
import os.log
import SwiftUI

struct GPWUserNotificationsSettingsView: View {
    @EnvironmentObject private var user: GPWUserViewModel

    var body: some View {
        ZStack {
            GPWForm(settings: $user.settings)
        }
        .navigationTitle("Notifications")
    }
}

private extension GPWUserNotificationsSettingsView {
    struct GPWForm: View {
        @Binding var settings: GPWCKUserSettings

        @State private var isEnabled = GPWCKUserSettings.default.notifications.isEnabled
        @State private var onMessageReceived = GPWCKUserSettings.default.notifications.onMessageReceived
        @State private var onDeviceAdded = GPWCKUserSettings.default.notifications.onDeviceAdded
        @State private var onDeviceRemoved = GPWCKUserSettings.default.notifications.onDeviceRemoved

        @EnvironmentObject private var user: GPWUserViewModel

        init(settings: Binding<GPWCKUserSettings>) {
            _settings = settings
        }

        private var isEnabledField: some View {
            GPWToggleField(title: "Enable notifications", value: $isEnabled, referenceValue: settings.notifications.isEnabled) {
                try await user.updateSettings(
                    GPWCKUserSettings(
                        notifications: GPWCKUserNotificationsSettings(
                            isEnabled: isEnabled,
                            onMessageReceived: settings.notifications.onMessageReceived,
                            onDeviceAdded: settings.notifications.onDeviceAdded,
                            onDeviceRemoved: settings.notifications.onDeviceRemoved
                        )
                    )
                )
            }
        }

        private var onMessageReceivedField: some View {
            GPWToggleField(title: "Message recevied", value: $onMessageReceived, referenceValue: settings.notifications.onMessageReceived) {
                try await user.updateSettings(
                    GPWCKUserSettings(
                        notifications: GPWCKUserNotificationsSettings(
                            isEnabled: settings.notifications.isEnabled,
                            onMessageReceived: onMessageReceived,
                            onDeviceAdded: settings.notifications.onDeviceAdded,
                            onDeviceRemoved: settings.notifications.onDeviceRemoved
                        )
                    )
                )
            }
        }

        private var onDeviceAddedField: some View {
            GPWToggleField(title: "Device added", value: $onDeviceAdded, referenceValue: settings.notifications.onDeviceAdded) {
                try await user.updateSettings(
                    GPWCKUserSettings(
                        notifications: GPWCKUserNotificationsSettings(
                            isEnabled: settings.notifications.isEnabled,
                            onMessageReceived: settings.notifications.onMessageReceived,
                            onDeviceAdded: onDeviceAdded,
                            onDeviceRemoved: settings.notifications.onDeviceRemoved
                        )
                    )
                )
            }
        }

        private var onDeviceRemovedField: some View {
            GPWToggleField(title: "Device removed", value: $onDeviceRemoved, referenceValue: settings.notifications.onDeviceRemoved) {
                try await user.updateSettings(
                    GPWCKUserSettings(
                        notifications: GPWCKUserNotificationsSettings(
                            isEnabled: settings.notifications.isEnabled,
                            onMessageReceived: settings.notifications.onMessageReceived,
                            onDeviceAdded: settings.notifications.onDeviceAdded,
                            onDeviceRemoved: onDeviceRemoved
                        )
                    )
                )
            }
        }

        private var notificationPreferencesSection: some View {
            Section {
                onMessageReceivedField
                onDeviceAddedField
                onDeviceRemovedField
            } header: {
                Text("Preferences")
            }
            .disabled(!isEnabled)
        }

        var body: some View {
            Form {
                Section {
                    isEnabledField
                } header: {
                    Text("General")
                }
                notificationPreferencesSection
            }
            .onAppear {
                isEnabled = settings.notifications.isEnabled
                onMessageReceived = settings.notifications.onMessageReceived
                onDeviceAdded = settings.notifications.onDeviceAdded
                onDeviceRemoved = settings.notifications.onDeviceRemoved
            }
            .onChange(of: settings) { _, settings in
                isEnabled = settings.notifications.isEnabled
                onMessageReceived = settings.notifications.onMessageReceived
                onDeviceAdded = settings.notifications.onDeviceAdded
                onDeviceRemoved = settings.notifications.onDeviceRemoved
            }
        }
    }

    struct GPWToggleField: View {
        let title: String
        @Binding var value: Bool
        let referenceValue: Bool
        let onChange: () async throws -> Void

        init(title: String, value: Binding<Bool>, referenceValue: Bool, onChange: @escaping () async throws -> Void) {
            self.title = title
            _value = value
            self.referenceValue = referenceValue
            self.onChange = onChange
        }

        var body: some View {
            Toggle(title, isOn: $value)
                .onChange(of: value) { oldValue, newValue in
                    if oldValue == referenceValue, newValue != referenceValue {
                        Task {
                            do {
                                try await onChange()
                            } catch {
                                value = oldValue
                                Logger().error("[GPWUserNotificationsSettingsView] Unable to set `\(title)` to \(newValue): \(error.localizedDescription)")
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    GPWUserNotificationsSettingsView()
}
