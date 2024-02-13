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

import SwiftUI

struct GPWUserMainView: View {
    @StateObject private var userNotification = GPWUserNotificationViewModel()
    @StateObject private var userLocalDevice = GPWUserLocalDeviceViewModel()

    @State private var selectedTab = GPWTab.contactList

    @EnvironmentObject private var user: GPWUserViewModel
    @EnvironmentObject private var userAccount: GPWUserAccountViewModel

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            GPWTabItem(tag: .contactList) {
                GPWUserContactListView()
            } label: {
                Label("Contacts", systemImage: "person.3.fill")
            }
            GPWTabItem(tag: .chatList) {
                GPWUserChatListView()
            } label: {
                Label("Chats", systemImage: "rectangle.3.group.bubble.fill")
            }
            GPWTabItem(tag: .profile) {
                GPWUserProfileView()
            } label: {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
        .environmentObject(userLocalDevice)
        .environmentObject(userNotification)
        .navigationTitle(selectedTab.rawValue)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: GPWNavigationDestination.self) { destination in
            switch destination {
                case .userAccount: GPWUserAccountView()
                case .userDeviceList: GPWUserDeviceListView()
                case .userNotificationsSettings: GPWUserNotificationsSettingsView()
                case .userSettings: GPWUserSettingsView()
                case .about: GPWAboutView()
            }
        }
    }

    var body: some View {
        ZStack {
            if let userId = userAccount.userId {
                tabView
                    .onAppear {
//                        userLocalDevice.subscribe(userId: userId)
                        userNotification.subscribe(userId: userId)
                    }
//                    .sheet(isPresented: $showUserNotificationsConsentSheet) {
//                        <#code#>
//                    }
            } else {
                ProgressView {
                    Text("Loading ...")
                }
            }
        }
    }
}

private extension GPWUserMainView {
    struct GPWTabItem<GPWContent: View, GPWLabel: View>: View {
        let tag: GPWTab

        @ViewBuilder let content: () -> GPWContent
        @ViewBuilder let label: () -> GPWLabel

        var body: some View {
            ZStack {
                ZStack {
                    content()
                    VStack {
                        Spacer()
                        Divider()
                            .background {
                                Color.gray
                            }
                            .shadow(radius: 1)
                            .padding(.bottom, 8)
                    }
                }
            }
            .tag(tag)
            .tabItem {
                label()
            }
        }
    }
}

extension GPWUserMainView {
    enum GPWTab: String {
        case contactList = "Contacts"
        case chatList = "Chats"
        case profile = "Profile"
    }
}

#Preview {
    GPWUserMainView()
}
