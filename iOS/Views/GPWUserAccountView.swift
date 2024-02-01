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

struct GPWUserAccountView: View {
    @EnvironmentObject private var userAccount: GPWUserAccountViewModel

    @State private var showDeleteUserAccountConfirmationDialog = false

    private func deleteUserAccount() {
        Task {
            do {
                try await userAccount.delete()
            } catch {
                Logger().error("GPWUserAccountScreen: Unable to delete user account: \(error.localizedDescription)")
            }
        }
    }

    private var accountDetailSection: some View {
        Section {
            GPWCell(title: "Display QR code", image: Image(systemName: "qrcode.viewfinder"))
        } header: {
            Text("Account details")
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive, action: { showDeleteUserAccountConfirmationDialog.toggle() }) {
                GPWCell(title: "Delete my account", image: Image(systemName: "rectangle.portrait.and.arrow.right"))
            }
            .buttonStyle(.gpwPlain)
            .listRowInsets(EdgeInsets())
        } header: {
            Text("Danger")
        }
    }

    var body: some View {
        List {
            accountDetailSection
            dangerSection
        }
        .navigationTitle("Account")
        .confirmationDialog("Are you sure ?", isPresented: $showDeleteUserAccountConfirmationDialog) {
            Button("Delete my account !!", role: .destructive, action: deleteUserAccount)
            Button("Please cancel", role: .cancel, action: {})
                .keyboardShortcut(.defaultAction)
        }
    }
}

private extension GPWUserAccountView {
    struct GPWCell: View {
        let title: String
        let image: Image

        var body: some View {
            HStack(spacing: 16) {
                image
                    .frame(width: 32, alignment: .leading)
                Text(title)
                    .font(.gpwHeadline)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
    }

    struct GPWNavigationCell: View {
        let title: String
        let image: Image
        let destination: GPWUserMainView.GPWDestination

        var body: some View {
            NavigationLink(value: destination) {
                GPWCell(title: title, image: image)
            }
        }
    }
}

#Preview {
    GPWUserAccountView()
}
