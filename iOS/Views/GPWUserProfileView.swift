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

import os.log
import SwiftUI

struct GPWUserProfileView: View {
    @EnvironmentObject private var user: GPWUserViewModel

    private var userMenu: some View {
        VStack(spacing: 0) {
            GPWCell(title: "Account", image: Image(systemName: "person"), destination: .userAccount)
            GPWCell(title: "Devices", image: Image(systemName: "smartphone"), destination: .userDevices)
            GPWCell(title: "Settings", image: Image(systemName: "slider.horizontal.3"), destination: .settings)

            Divider()
                .background(Color.gray)
                .padding(.horizontal)

            //            GPWCell(title: "Help", image: Image(systemName: "questionmark.circle"), destination: .help)
            GPWCell(title: "About", image: Image(systemName: "info.circle"), destination: .about)
        }
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

extension GPWUserProfileView {
    private struct GPWCell: View {
        let title: String
        let image: Image
        let destination: GPWUserMainView.GPWDestination

        var body: some View {
            NavigationLink(value: destination) {
                HStack {
                    image
                        .frame(width: 32, alignment: .leading)
                    Text(title)
                        .font(.gpwHeadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .frame(width: 32, alignment: .trailing)
                }
                .padding()
            }
            .tint(.black)
        }
    }
}

#Preview {
    GPWUserProfileView()
}
