//
//  swift-ui-kit-oskey-dev
//  Copyright (c) OSKEY SAS. All rights reserved.
//
//  The source code is protected under international copyright law.  All rights
//  reserved and protected by the copyright holders.
//
//  The source code is confidential and only available to authorized individuals
//  with the permission of the copyright holders.  If you encounter this this source
//  code and do not have permission, please contact the copyright holders and delete
//  this file.
//

import SwiftUI

@available(iOS 16, watchOS 9, *)
public struct GPWNavigationStack<OSKUINavigationRoute: Hashable, OSKDestination: View>: View {
    let root: OSKUINavigationRoute

    @ViewBuilder let destination: (_ route: OSKUINavigationRoute) -> OSKDestination

    @StateObject private var navigationStack = GPWNavigationStackViewModel<OSKUINavigationRoute>()

    public init(root: OSKUINavigationRoute, destination: @escaping (OSKUINavigationRoute) -> OSKDestination) {
        self.root = root
        self.destination = destination
        
//        let coloredAppearance = UINavigationBarAppearance()
//        coloredAppearance.configureWithTransparentBackground()
//        coloredAppearance.backgroundColor = .clear
//        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(.gpwOnPrimary)]
//        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(.gpwOnPrimary)]
//        
//        UINavigationBar.appearance().standardAppearance = coloredAppearance
//        UINavigationBar.appearance().compactAppearance = coloredAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
//        UINavigationBar.appearance().tintColor = UIColor(.gpwPrimary)
    }

    public var body: some View {
        NavigationStack(path: $navigationStack.path) {
            destination(root)
                .navigationDestination(for: OSKUINavigationRoute.self) { route in
                    destination(route)
                }
                .tint(.gpwPrimary)
        }
        .environmentObject(navigationStack)
        .tint(.gpwOnPrimary)
    }
}
