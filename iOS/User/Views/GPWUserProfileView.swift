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

struct GPWUserProfileView: View {
    @ScaledMetric(relativeTo: .body) private var spacing = 16

    @EnvironmentObject private var user: GPWUserViewModel

    private func navigationCell(value: GPWNavigationDestination, title: String, systemImage: String) -> some View {
        GPWNavigationCell(value: value) {
            Text(title)
        } leading: {
            Image(systemName: systemImage)
        }
    }

    private var userMenu: some View {
        VStack(spacing: spacing) {
            navigationCell(value: .userAccount, title: "Account", systemImage: "person")
            navigationCell(value: .userDeviceList, title: "Devices", systemImage: "smartphone")
            navigationCell(value: .userSettings, title: "Settings", systemImage: "slider.horizontal.3")

            Divider()
                .background(Color.gray)

            navigationCell(value: .about, title: "About", systemImage: "info.circle")
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
        }
    }

    private var content: some View {
        VStack {
            Spacer()

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 256, maxHeight: 256)
                .foregroundColor(.accentColor)

            Text(user.displayName)
                .font(.gpwTitle)
                .bold()

            Spacer()

            userMenu
        }
    }

    var body: some View {
        content
            .padding()
            .padding(.vertical)
    }
}

#Preview {
    GPWUserProfileView()
}
