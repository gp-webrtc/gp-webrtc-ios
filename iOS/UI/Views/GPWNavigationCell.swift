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

struct GPWNavigationCell<GPWLeading: View, GPWTitle: View, GPWSubtitle: View, GPWTrailing: View>: View {
    let destination: GPWNavigationDestination
    @ViewBuilder let title: () -> GPWTitle
    @ViewBuilder let leading: () -> GPWLeading
    @ViewBuilder let subtitle: () -> GPWSubtitle
    @ViewBuilder let trailing: () -> GPWTrailing

    @Environment(\.colorScheme) private var colorScheme

    init(
        value destination: GPWNavigationDestination,
        @ViewBuilder title: @escaping () -> GPWTitle,
        @ViewBuilder leading: @escaping () -> GPWLeading = { EmptyView() },
        @ViewBuilder subtitle: @escaping () -> GPWSubtitle = { EmptyView() },
        @ViewBuilder trailing: @escaping () -> GPWTrailing = { EmptyView() }
    ) {
        self.destination = destination
        self.title = title
        self.leading = leading
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        NavigationLink(value: destination) {
            GPWCell(title: title, leading: leading, subtitle: subtitle, trailing: trailing)
        }
        .tint(colorScheme == .light ? .black : .white)
    }
}

#Preview {
    List {
        GPWNavigationCell(value: GPWNavigationDestination.userAccount) {
            Text("This is a navigation cell")
        }
    }
}
