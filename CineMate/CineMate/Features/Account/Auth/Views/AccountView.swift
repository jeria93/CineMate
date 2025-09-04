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
            Color.clear
                .ignoresSafeArea()

            Form {
                if let uid = authViewModel.currentUID {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Account", systemImage: "person.crop.circle")
                                .font(.headline)

                            Text("Signed in as \(uid.prefix(6))")
                                .foregroundStyle(.secondary)

                            Button("Sign out") { authViewModel.signOut() }
                                .buttonStyle(.borderedProminent)
                                .disabled(authViewModel.isAuthenticating)
                        }
                        .padding(.vertical, 4)
                    }

                    // Danger Zone (delete)
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

            // FULLSKÄRMS-LOADING (täcker allt vid radering/inloggning)
            if authViewModel.isAuthenticating {
                LoadingView(title: "Working…")
                    .transition(.opacity)
                    .zIndex(2)
            }

            // FULLSKÄRMS-FEL (täcker allt)
            if let error = authViewModel.errorMessage {
                ErrorMessageView(
                    title: "Authentication Error",
                    message: error,
                    onRetry: { authViewModel.errorMessage = nil }
                )
                .transition(.opacity)
                .zIndex(3)
            }
        }
        .animation(.default, value: authViewModel.isAuthenticating)
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
