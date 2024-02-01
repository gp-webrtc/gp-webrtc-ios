//
// gp-webrtc/ios
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
    @StateObject private var user = GPWUserViewModel()

    @State private var selectedTab = GPWTab.contactList
    @State private var path = NavigationPath()

    @EnvironmentObject private var userAccount: GPWUserAccountViewModel

    private func tabView(userId: String) -> some View {
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
        .onAppear {
            user.subscribe(userId: userId)
        }
    }

    private var content: some View {
        ZStack {
            if let userId = userAccount.userId {
                NavigationStack(path: $path) {
                    tabView(userId: userId)
                        .navigationTitle(selectedTab.rawValue)
                        .toolbar(.hidden, for: .navigationBar)
                        .navigationDestination(for: GPWDestination.self) { destination in
                            switch destination {
                                case .userAccount: GPWUserAccountView()
                                case .userDevices: GPWUserDevicesView()
                                case .settings: GPWSetttingsScreen()
                                case .about: GPWAboutScreen()
                            }
                        }
                }
            } else {
                ProgressView {
                    Text("Loading ...")
                }
            }
        }
    }

    var body: some View {
        content
            .environmentObject(user)
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
    enum GPWDestination: Hashable {
        case userAccount
        case userDevices
        case settings
        case about
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
