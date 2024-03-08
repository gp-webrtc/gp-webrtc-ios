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

struct GPWCell<GPWLeading: View, GPWTitle: View, GPWSubtitle: View, GPWTrailing: View>: View {
    @ScaledMetric(relativeTo: .body) private var spacing = 16
    @ScaledMetric(relativeTo: .body) private var width = 24
    @ScaledMetric(relativeTo: .body) private var height = 24

    @ViewBuilder let title: () -> GPWTitle
    @ViewBuilder let leading: () -> GPWLeading
    @ViewBuilder let subtitle: () -> GPWSubtitle
    @ViewBuilder let trailing: () -> GPWTrailing

    init(
        @ViewBuilder title: @escaping () -> GPWTitle,
        @ViewBuilder leading: @escaping () -> GPWLeading = { EmptyView() },
        @ViewBuilder subtitle: @escaping () -> GPWSubtitle = { EmptyView() },
        @ViewBuilder trailing: @escaping () -> GPWTrailing = { EmptyView() }
    ) {
        self.title = title
        self.leading = leading
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: spacing) {
            if !(leading is () -> EmptyView) {
                leading()
                    .frame(width: width, height: height, alignment: .center)
            }
//            image
            VStack(alignment: .leading, spacing: 0) {
                title()
                    .font(.gpwHeadline)
                    .fontWeight(.semibold)
                if !(subtitle is () -> EmptyView) {
                    subtitle()
                        .font(.gpwSubheadline)
                        .fontWeight(.light)
                        .italic()
                }
            }
            Spacer()
            if !(trailing is () -> EmptyView) {
                trailing()
                    .font(.gpwSubheadline)
                    .fontWeight(.light)
                    .italic()
                    .frame(height: height, alignment: .center)
            }
        }
    }
}

#Preview {
    List {
        GPWCell {
            Text("This is a cell")
        }
    }
}
