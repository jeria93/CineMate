//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var toastCenter: ToastCenter

    init(viewModel: AuthViewModel) {
        self._authViewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Form {
                if let uid = authViewModel.currentUID {
                    // Signed-in section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Account", systemImage: "person.crop.circle")
                                .font(.headline)

                            Text("Signed in as \(uid.prefix(6))")
                                .foregroundStyle(.secondary)

                            HStack {
                                Text("Sign-in method")
                                Spacer()
                                Text(authViewModel.authProviderDescription)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }

                            Button("Sign out") {
                                authViewModel.signOut()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(authViewModel.isAuthenticating)
                        }
                        .padding(.vertical, 4)
                    }

                    // Danger Zone (delete account)
                    AccountDangerZoneView(
                        authViewModel: authViewModel,
                        onReauthenticationRequired: {
                            toastCenter.show("Please sign in again to delete your account")
                            authViewModel.signOut()
                        },
                        onDeleteSuccess: {
                            toastCenter.show("Account deleted successfully")
                        },
                        onDeleteFailure: { message in
                            toastCenter.show(message)
                        }
                    )
                }
            }
            .navigationTitle("Account")
            .disabled(authViewModel.isAuthenticating)

            if let error = authViewModel.errorMessage {
                ErrorMessageView(
                    title: "Authentication Error",
                    message: error,
                    onRetry: { authViewModel.errorMessage = nil }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.default, value: authViewModel.errorMessage != nil)
    }
}

#Preview("Signed In") {
    AccountView.previewSignedIn
}

#Preview("Signed Out") {
    AccountView.previewSignedOut
}

#Preview("Error") {
    AccountView.previewError
}

#Preview("Is Authenticating") {
    AccountView.previewIsAuthenticating
}
