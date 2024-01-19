//
//  GPWProfileView.swift
//  iOS
//
//  Created by Greg PFISTER on 19/01/2024.
//

import SwiftUI

struct GPWProfileView: View {
    @EnvironmentObject private var user: GPWUserViewModel
    @EnvironmentObject private var userAccount: GPWUserAccountViewModel

    @State private var path = NavigationPath()

    private func signOut() {
        userAccount.signOut()
    }

    var content: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 256, maxHeight: 256)
                .foregroundColor(.accentColor)

            Text(user.displayName)

            Spacer()

            Button(action: signOut) {
                HStack {
                    Spacer()
                    Text("Sign out")
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .padding()
                .padding(.vertical)
                .navigationTitle("Profile")
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    GPWProfileView()
}
