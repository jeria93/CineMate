//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Account screen with session info and account actions.
struct AccountView: View {
    @ObservedObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingChangeEmailSheet = false
    @State private var isShowingTermsSheet = false
    @State private var hasReviewedUpdates = false

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

                    if !authViewModel.isGuest {
                        Section("Email") {
                            if let email = authViewModel.currentUserEmail {
                                HStack {
                                    Text("Current email")
                                    Spacer()
                                    Text(email)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            }

                            if authViewModel.canChangeEmail {
                                Button("Change email") {
                                    isShowingChangeEmailSheet = true
                                }
                                .buttonStyle(.bordered)
                                .disabled(authViewModel.isAuthenticating)
                            } else {
                                Text("Email change is only available for email accounts.")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }

                    if !authViewModel.isGuest {
                        Section("Legal") {
                            if let summary = authViewModel.acceptedTermsSummaryText {
                                Text(summary)
                                    .foregroundStyle(Color.appTextSecondary)
                            } else {
                                Text("No saved terms acceptance for this account yet.")
                                    .foregroundStyle(Color.appTextSecondary)
                            }

                            if authViewModel.isAcceptedTermsOutdated {
                                Button {
                                    let wasReviewed = hasReviewedUpdates
                                    hasReviewedUpdates = true
                                    if !wasReviewed {
                                        toastCenter.show("Review complete. You can accept the update.")
                                    }
                                    isShowingTermsSheet = true
                                } label: {
                                    Label(
                                        hasReviewedUpdates ? "Reviewed" : "Review updates",
                                        systemImage: hasReviewedUpdates ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                                    )
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(hasReviewedUpdates ? Color.appTextSecondary : .orange)
                                }
                                .buttonStyle(.plain)
                            } else if authViewModel.acceptedTermsSummaryText != nil {
                                Label("Up to date", systemImage: "checkmark.seal.fill")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.green)
                            }

                            if let appVersion = authViewModel.acceptedTermsAppVersionText {
                                HStack {
                                    Text("App version")
                                    Spacer()
                                    Text(appVersion)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            }

                            Button("View terms") {
                                isShowingTermsSheet = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(authViewModel.isAuthenticating)

                            if authViewModel.isAcceptedTermsOutdated || authViewModel.acceptedTermsSummaryText == nil {
                                let requiresReviewBeforeAccept = authViewModel.isAcceptedTermsOutdated && !hasReviewedUpdates

                                Button(authViewModel.isAcceptedTermsOutdated ? "Accept update" : "Accept latest terms") {
                                    Task {
                                        let result = await authViewModel.acceptCurrentTermsVersion()
                                        handleAcceptTermsResult(result)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.appPrimaryAction)
                                .disabled(
                                    authViewModel.isAuthenticating || requiresReviewBeforeAccept
                                )

                                if requiresReviewBeforeAccept {
                                    Text("Review required before accepting.")
                                        .font(.footnote)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                        }

                        Section("Security") {
                            if authViewModel.canSendPasswordReset {
                                if let email = authViewModel.currentUserEmail {
                                    Text("Reset links are sent to \(email).")
                                        .foregroundStyle(Color.appTextSecondary)
                                }

                                Button("Change password") {
                                    Task {
                                        switch await authViewModel.sendPasswordResetForCurrentUser() {
                                        case .sent(let email):
                                            toastCenter.show("Password reset link sent to \(email).")
                                        case .unavailable:
                                            toastCenter.show("Password reset is only available for email sign in.")
                                        case .failure(let message):
                                            toastCenter.show(message)
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(authViewModel.isAuthenticating)
                            } else {
                                Text("Password reset is only available for email accounts.")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }

                    Section("Actions") {
                        Button(authViewModel.isGuest ? "End guest session" : "Sign out") {
                            Task {
                                let wasGuest = authViewModel.isGuest
                                await authViewModel.signOut()
                                if wasGuest, authViewModel.errorMessage == nil {
                                    toastCenter.show("Guest session ended.")
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimaryAction)
                        .disabled(authViewModel.isAuthenticating)
                    }

                    if !authViewModel.isGuest {
                        AccountDangerZoneView(
                            authViewModel: authViewModel,
                            onReauthenticationRequired: {
                                toastCenter.show("Please sign in again to delete your account.")
                            },
                            onDeleteSuccess: {
                                toastCenter.show("Account deleted.")
                            },
                            onDeleteFailure: { message in
                                toastCenter.show(message)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Account")
            .disabled(authViewModel.isAuthenticating)
            .sheet(isPresented: $isShowingChangeEmailSheet) {
                ChangeEmailSheet(
                    currentEmail: authViewModel.currentUserEmail,
                    onSubmit: { newEmail in
                        await authViewModel.sendChangeEmailVerification(to: newEmail)
                    },
                    onResult: { result in
                        handleChangeEmailResult(result)
                    }
                )
            }
            .sheet(isPresented: $isShowingTermsSheet) {
                TermsSheet(markdown: TermsContent.termsMarkdown)
            }

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
        .task(id: authViewModel.currentUID) {
            await authViewModel.refreshTermsAcceptance()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await authViewModel.refreshCurrentUserFromServer() }
        }
        .onChange(of: authViewModel.isAcceptedTermsOutdated) { _, isOutdated in
            if isOutdated {
                hasReviewedUpdates = false
            } else {
                hasReviewedUpdates = true
            }
        }
    }

    private func handleChangeEmailResult(_ result: AuthViewModel.ChangeEmailResult) {
        switch result {
        case .verificationSent(let email):
            toastCenter.show("Verification link sent to \(email).")
        case .unavailable:
            toastCenter.show("Email change is only available for email sign in.")
        case .cooldown(let seconds):
            toastCenter.show("Wait \(seconds) seconds before sending another link.")
        case .needsRecentLogin:
            toastCenter.show("Please sign in again to change your email.")
        case .failure(let message):
            toastCenter.show(message)
        }
    }

    private func handleAcceptTermsResult(_ result: AuthViewModel.AcceptTermsResult) {
        switch result {
        case .saved:
            toastCenter.show("Accepted terms version \(TermsContent.currentVersion).")
        case .unavailable:
            toastCenter.show("Terms acceptance not available for this account.")
        case .failure(let message):
            toastCenter.show(message)
        }
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
