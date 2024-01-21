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

struct GPWUserDevicesView: View {
    @StateObject private var userDevices = GPWUserDeviceListViewModel()

    var body: some View {
        List(userDevices.devices) { userDevice in
            GPWCell(title: userDevice.displayName, image: Image(systemName: "iphone.gen3"))
        }
        .navigationTitle("Devices")
    }
}

private extension GPWUserDevicesView {
    struct GPWCell: View {
        let title: String
        let image: Image

        var body: some View {
            HStack(spacing: 16) {
                image
                    .frame(width: 32, alignment: .leading)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
    }

    struct GPWNavigationCell: View {
        let title: String
        let image: Image
        let destination: GPWUserProfileView.GPWDestination

        var body: some View {
            NavigationLink(value: destination) {
                GPWCell(title: title, image: image)
            }
        }
    }
}

#Preview {
    GPWUserDevicesView()
}
