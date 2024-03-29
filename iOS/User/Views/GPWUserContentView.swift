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

import os.log
import SwiftUI

struct GPWUserContentView: View {
    let userId: String
    
    @ScaledMetric(relativeTo: .body) private var spacing = 16
    
    @State private var isUpdating = false
    @State private var path = NavigationPath()
    
    @StateObject private var coreVersion = GPWCoreVersionViewModel()
    @StateObject private var user = GPWUserViewModel()
    @EnvironmentObject private var userAccount: GPWUserAccountViewModel
    
#if DEBUG
    func deleteAccount() {
        Task {
            try? await userAccount.delete()
        }
    }
#endif
    
    private var mustUpdateApp: some View {
        VStack(spacing: spacing) {
            Image(systemName: "cloud.bolt")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.red)
            Text("You must update your app\nto the version \(coreVersion.targetIOSVersion ?? "UNKNOWN_VERISON") or above")
                .multilineTextAlignment(.center)
        }
    }
    
    private var mustUpdateData: some View {
        VStack(spacing: spacing) {
            Image(systemName: "exclamationmark.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.accentColor)
            Text("You must update your app data\nto the version \(coreVersion.targetModelVersion ?? "UNKNOWN_VERISON")")
                .multilineTextAlignment(.center)
            if !isUpdating {
                Button {
                    isUpdating = true
                    Task {
                        do {
                            try await coreVersion.updateModel(to: coreVersion.targetModelVersion!, userId: userId)
                        } catch {
                            Logger().error("[GPWUserContentView] Unable to update data: \(error.localizedDescription)")
                        }
                    }
                    isUpdating = false
                } label: {
                    Text("Update data")
                }
                .buttonStyle(.gpwPlain)
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
            }
        }
    }
    
    var body: some View {
        ZStack {
            if user.isLoading || coreVersion.isLoading {
                VStack {
                    Spacer()
                    ProgressView("We are sorting out your citizenship...")
                    Spacer()
#if DEBUG
                    Divider()
                    Button(role: .destructive) { deleteAccount() } label: {
                        Text("Delete account")
                    }
                    .buttonStyle(.gpwFlat)
#endif
                }
            } else {
                if coreVersion.mustUpdateApp {
                    mustUpdateApp
                        .padding()
                } else if coreVersion.mustUpdateData {
                    mustUpdateData
                        .padding()
                } else {
                    GPWUserContextView(userId: userId)
                        .environmentObject(user)
                }
            }
        }
        .gpwSubscriber {
            user.subscribe(userId: userId)
            coreVersion.subscribe(userId: userId)
        } unsubscribe: {
            user.unsubscribe()
            coreVersion.unsubscribe()
        }
        .onReceive(user.$modelVersion) { modelVersion in
            coreVersion.modelVersion = modelVersion
        }
    }
}

private extension GPWUserContentView {
    struct GPWUserContextView: View {
        let userId: String
        
        @StateObject private var userNotification = GPWUserNotificationViewModel()
//        @StateObject private var userLocalDevice = GPWUserLocalDeviceViewModel()
        
        var body: some View {
            ZStack {
                GPWNavigationStack(root: GPWNavigationDestination.root) { destination in
                    ZStack {
                        switch (destination) {
                        case .root: GPWUserMainView(userId: userId)
                        case .userAccount: GPWUserAccountView()
                        case let .userDeviceList(userId: userId): GPWUserDeviceListView(userId: userId)
                        case .userNotificationsSettings: GPWUserNotificationsSettingsView()
                        case .userSettings: GPWUserSettingsView()
                        case .about: GPWAboutView()
                        }
                    }
                }
            }
            .gpwSubscriber {
                //                        userLocalDevice.subscribe(userId: userId)
                userNotification.subscribe(userId: userId)
            } unsubscribe: {
                //                        userLocalDevice.unsubscribe()
                userNotification.unsubcribe()
            }
//            .environmentObject(userLocalDevice)
            .environmentObject(userNotification)
        }
    }
}
