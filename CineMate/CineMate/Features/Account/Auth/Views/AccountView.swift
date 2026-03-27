//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Account screen with session info, provider info, actions, and danger zone.
struct AccountView: View {
    @ObservedObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter

    init(viewModel: AuthViewModel) {
        self._authViewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Form {
                Section("Session") {
                    if let uid = authViewModel.currentUID {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Signed in", systemImage: "person.crop.circle.fill")
                                .font(.headline)
                            Text("User ID: \(uid.prefix(10))")
                                .foregroundStyle(Color.appTextSecondary)
                                .font(.footnote.monospaced())
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Signed out", systemImage: "person.crop.circle.badge.xmark")
                                .font(.headline)
                            Text("Sign in to manage your account.")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }

                if authViewModel.isSignedIn {
                    Section("Provider") {
                        HStack {
                            Text("Sign-in method")
                            Spacer()
                            Text(authViewModel.authProviderDescription)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    if authViewModel.isGuest {
                        Section("Guest account") {
                            Text("Create an account to unlock Discover and Search.")
                                .foregroundStyle(Color.appTextSecondary)

                            Button("Create Account") {
                                navigator.goToCreateAccount()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.appPrimaryAction)
                            .disabled(authViewModel.isAuthenticating)
                        }
                    }

                    Section("Actions") {
                        Button("Sign out") {
                            authViewModel.signOut()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimaryAction)
                        .disabled(authViewModel.isAuthenticating)
                    }

                    AccountDangerZoneView(
                        authViewModel: authViewModel,
                        onReauthenticationRequired: {
                            toastCenter.show("Please sign in again to delete your account")
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
