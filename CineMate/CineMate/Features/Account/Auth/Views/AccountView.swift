//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI
import UIKit

/// Owns account navigation, sheet presentation, copy actions, server refresh, and local feedback.
/// Child section views stay presentation-focused.
struct AccountView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject var toastCenter: ToastCenter
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingChangeEmailSheet = false
    @State private var isShowingTermsSheet = false
    @State var changeEmailFeedback: AccountInlineFeedback?
    @State var passwordResetFeedback: AccountInlineFeedback?
    @State var legalFeedback: AccountInlineFeedback?
    @State var isSendingPasswordReset = false
    @State var isAcceptingLatestTerms = false
    @State private var isRefreshingAccount = false
    @State private var lastAccountRefreshDate: Date?

    init(viewModel: AuthViewModel) {
        self._authViewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    AccountSummarySectionView(
                        title: accountSummaryContent.title,
                        detail: accountSummaryContent.detail,
                        iconSystemName: accountSummaryContent.iconSystemName,
                        providerDescription: accountSummaryContent.providerDescription,
                        userID: accountSummaryContent.userID,
                        copyEmail: copyableEmail,
                        copyUserID: authViewModel.currentUID,
                        onCopyEmail: { value in
                            copyToPasteboard(value, toastMessage: "Email copied.")
                        },
                        onCopyUserID: { value in
                            copyToPasteboard(value, toastMessage: "User ID copied.")
                        }
                    )
                }

                if let errorMessage = authViewModel.errorMessage,
                   changeEmailFeedback == nil,
                   passwordResetFeedback == nil,
                   legalFeedback == nil {
                    Section {
                        AccountErrorMessageView(
                            message: errorMessage,
                            onDismiss: {
                                authViewModel.errorMessage = nil
                            }
                        )
                    }
                }

                if authViewModel.isSignedIn {
                    if authViewModel.isGuest {
                        GuestAccountSectionView(
                            isAuthenticating: authViewModel.isAuthenticating,
                            onCreateAccount: {
                                navigator.goToCreateAccount()
                            }
                        )
                    }

                    if !authViewModel.isGuest {
                        AccountSecuritySectionView(
                            model: AccountSecuritySectionModel(
                                currentEmail: authViewModel.currentUserEmail,
                                canChangeEmail: authViewModel.canChangeEmail,
                                canSendPasswordReset: authViewModel.canSendPasswordReset,
                                isAuthenticating: isSendingPasswordReset,
                                isSendingPasswordReset: isSendingPasswordReset,
                                changeEmailFeedback: changeEmailFeedback,
                                passwordResetFeedback: passwordResetFeedback
                            ),
                            onChangeEmail: {
                                changeEmailFeedback = nil
                                isShowingChangeEmailSheet = true
                            },
                            onChangePassword: {
                                Task {
                                    isSendingPasswordReset = true
                                    passwordResetFeedback = nil
                                    defer { isSendingPasswordReset = false }

                                    switch await authViewModel.sendPasswordResetForCurrentUser() {
                                    case .sent(let email):
                                        passwordResetFeedback = .success(
                                            "Password reset link sent to \(email). Check your inbox."
                                        )
                                        authViewModel.errorMessage = nil
                                    case .unavailable:
                                        passwordResetFeedback = .error("Password reset is only available for email sign in.")
                                        authViewModel.errorMessage = nil
                                    case .failure(let message):
                                        passwordResetFeedback = .error(message)
                                        authViewModel.errorMessage = nil
                                    }
                                }
                            }
                        )

                        AccountLegalSectionView(
                            model: AccountLegalSectionModel(
                                status: AccountLegalStatus(
                                    summaryText: authViewModel.acceptedTermsSummaryText,
                                    acceptedAtText: authViewModel.acceptedTermsAtText,
                                    isOutdated: authViewModel.isAcceptedTermsOutdated
                                ),
                                acceptedTermsVersionText: authViewModel.acceptedTermsVersionText,
                                acceptedPrivacyVersionText: authViewModel.acceptedPrivacyVersionText,
                                lastCheckedText: accountLastCheckedText,
                                shouldShowAcceptLatest: authViewModel.isAcceptedTermsOutdated
                                || authViewModel.acceptedTermsSummaryText == nil,
                                isAuthenticating: isAcceptingLatestTerms,
                                isAcceptingLatestTerms: isAcceptingLatestTerms,
                                feedback: legalFeedback
                            ),
                            onViewTerms: {
                                isShowingTermsSheet = true
                            },
                            onAcceptLatest: {
                                Task {
                                    isAcceptingLatestTerms = true
                                    legalFeedback = nil
                                    defer { isAcceptingLatestTerms = false }

                                    let result = await authViewModel.acceptCurrentTermsVersion()
                                    handleAcceptTermsResult(result)
                                }
                            }
                        )
                    }

                    AccountSessionSectionView(
                        isGuest: authViewModel.isGuest,
                        isAuthenticating: authViewModel.isAuthenticating,
                        onSignOut: {
                            Task {
                                let wasGuest = authViewModel.isGuest
                                await authViewModel.signOut()
                                if wasGuest, authViewModel.errorMessage == nil {
                                    toastCenter.show("Guest session ended.")
                                }
                            }
                        }
                    )

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await refreshAccountState(showToast: true) }
                    } label: {
                        if isRefreshingAccount {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("Refresh account", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(
                        isRefreshingAccount
                        || authViewModel.isAuthenticating
                        || !authViewModel.isSignedIn
                    )
                    .accessibilityLabel("Refresh account")
                }
            }
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
        }
        .animation(.default, value: authViewModel.errorMessage != nil)
        .task(id: authViewModel.currentUID) {
            await refreshAccountState(showToast: false)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await refreshAccountState(showToast: false) }
        }
    }

    private var accountSummaryContent: AccountSummaryContent {
        AccountSummaryContent(
            isSignedIn: authViewModel.isSignedIn,
            isGuest: authViewModel.isGuest,
            currentUserEmail: authViewModel.currentUserEmail,
            providerDescription: authViewModel.authProviderDescription,
            currentUID: authViewModel.currentUID
        )
    }

    private var copyableEmail: String? {
        guard let email = authViewModel.currentUserEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            return nil
        }
        return email
    }

    private var accountLastCheckedText: String? {
        lastAccountRefreshDate?.formatted(date: .abbreviated, time: .shortened)
    }

    /// Refreshes server-backed account state while avoiding duplicate refresh tasks.
    @MainActor
    private func refreshAccountState(showToast: Bool) async {
        guard authViewModel.isSignedIn else { return }
        guard !isRefreshingAccount else { return }

        isRefreshingAccount = true
        defer { isRefreshingAccount = false }

        await authViewModel.refreshCurrentUserFromServer()
        lastAccountRefreshDate = Date()

        if showToast {
            toastCenter.show("Account refreshed.")
        }
    }

    @MainActor
    private func copyToPasteboard(_ value: String, toastMessage: String) {
        UIPasteboard.general.string = value
        toastCenter.show(toastMessage)
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
