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

struct GPWContentView: View {
    @State private var path = NavigationPath()

    @StateObject private var userAccount = GPWUserAccountViewModel()

    private func signInAnonymously() {
        Task {
            do {
                try await userAccount.signInAnonymously()
            } catch {
                Logger().error("GPWContentView: Unable to sign in anonymously: \(error.localizedDescription)")
            }
        }
    }

    private var splash: some View {
        VStack {
            ZStack {
                HStack {
                    Text("Republik\nof free speech")
                        .font(.custom("Tourney", size: 34, relativeTo: .largeTitle))
                        .foregroundStyle(.accent)
                    Spacer()
                }
                .padding()
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .shadow(radius: 1)
            }
            .padding()
            .padding(.top, 48)

            Spacer()

            ZStack {
                if userAccount.authState == .signedOut {
                    Button(action: signInAnonymously) {
                        HStack {
                            Spacer()
                            Text("Join now, we need you !")
                            Spacer()
                        }
                    }
                    .buttonStyle(.gpwPlain)
                } else {
                    ProgressView {
                        Text("Loading ...")
                            .foregroundStyle(.white)
                    }
                }
            }

            .padding()
            .padding(.bottom)
        }
        .background(Image("GPWSplashScreen").resizable().scaledToFill())
        .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            if userAccount.authState == .signedIn, let userId = userAccount.userId {
                GPWUserContentView(userId: userId)
                    .environmentObject(userAccount)
            } else {
                splash
            }
        }
        .onAppear {
            userAccount.subscribe()
        }
    }
}

#Preview {
    GPWContentView()
}

// import SwiftUI
// import SwiftData
//
// struct GPContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [GPItem]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
// #if os(macOS)
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
// #endif
//            .toolbar {
// #if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
// #endif
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = GPItem(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
// }
//
// #Preview {
//    GPContentView()
//        .modelContainer(for: GPItem.self, inMemory: true)
// }
