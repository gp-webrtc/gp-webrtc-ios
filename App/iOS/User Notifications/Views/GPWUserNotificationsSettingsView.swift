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
        .gpwNavigationTitle("Notifications")
    }
}

private extension GPWUserNotificationsSettingsView {
    struct GPWForm: View {
        @Binding var settings: GPWCKUserSettings

        @State private var isEnabled = GPWCKUserSettings.default.notifications.isEnabled
        @State private var onDeviceAdded = GPWCKUserSettings.default.notifications.onDeviceAdded

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
                            onDeviceAdded: settings.notifications.onDeviceAdded
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
                            onDeviceAdded: onDeviceAdded
                        )
                    )
                )
            }
        }

        private var notificationPreferencesSection: some View {
            Section {
                onDeviceAddedField
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
                onDeviceAdded = settings.notifications.onDeviceAdded
            }
            .onChange(of: settings) { _, settings in
                isEnabled = settings.notifications.isEnabled
                onDeviceAdded = settings.notifications.onDeviceAdded
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
