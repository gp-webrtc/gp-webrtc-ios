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

public class GPWNavigationStackViewModel<OSKUINavigationRoute: Hashable>: ObservableObject {
    @Published var path = NavigationPath()

    private var stack: [OSKUINavigationRoute] = []

    public func push(route: OSKUINavigationRoute) {
        stack.append(route)
        path.append(route)
    }

    public func pop() {
        path.removeLast(1)
        stack.removeLast()
    }

    public func popTo(_ route: OSKUINavigationRoute) {
        while stack.last != route {
            stack.removeLast()
            pop()
        }
    }

    public func root() {
        path.removeLast(path.count)
        stack = []
    }
}
