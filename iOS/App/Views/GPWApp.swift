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
import SwiftData
import SwiftUI
import os.log

/// NavigationBar styling: https://swiftuirecipes.com/blog/navigation-bar-styling-in-swiftui

@main
struct GPWApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(GPWAppDelegate.self) var delegate

//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            GPWItem.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            GPWContentView()
                .environment(\.font, .gpwBody)
        }
        .onChange(of: scenePhase) { old, new in
            Logger().debug("[GPWApp] Change of scene phase: \(old.string) -> \(new.string)")
            if new == .background {
                GPWCKCloudAppService.shared.prepareForBackground()
            }
        }
//        .modelContainer(sharedModelContainer)
    }
}

extension ScenePhase {
    var string: String {
        switch(self) {
        case .active: "Active"
        case .background: "Background"
        case .inactive: "Inactive"
        @unknown default:
            fatalError("Scene phase \(self) is not handled")
        }
    }
}
