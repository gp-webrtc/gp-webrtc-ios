//
//  GPWProfileView.swift
//  iOS
//
//  Created by Greg PFISTER on 19/01/2024.
//

import os.log
import SwiftUI

struct GPWProfileView: View {
    @EnvironmentObject private var user: GPWUserViewModel
    @EnvironmentObject private var userAccount: GPWUserAccountViewModel

    @State private var path = NavigationPath()

    private func signOut() {
        do {
            try userAccount.signOut()
        } catch {
            Logger().error("GPWProfileView: Unable to sign out: \(error.localizedDescription)")
        }
    }

    private func deleteUserAccount() {
        Task {
            do {
                try await userAccount.delete()
            } catch {
                Logger().error("GPWProfileView: Unable to delete user account: \(error.localizedDescription)")
            }
        }
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
                    Text("Sign-out")
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive, action: deleteUserAccount) {
                HStack {
                    Spacer()
                    Text("Delete account")
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
