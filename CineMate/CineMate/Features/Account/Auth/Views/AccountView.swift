//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Owns account navigation, sheet presentation, and local feedback for async auth actions.
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
                        userID: accountSummaryContent.userID
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
                            currentEmail: authViewModel.currentUserEmail,
                            status: AccountSecurityStatus(
                                canChangeEmail: authViewModel.canChangeEmail,
                                canSendPasswordReset: authViewModel.canSendPasswordReset
                            ),
                            canChangeEmail: authViewModel.canChangeEmail,
                            canSendPasswordReset: authViewModel.canSendPasswordReset,
                            isAuthenticating: isSendingPasswordReset,
                            changeEmailFeedbackMessage: changeEmailFeedback?.message,
                            changeEmailFeedbackColor: changeEmailFeedback?.color,
                            passwordResetFeedbackMessage: passwordResetFeedback?.message,
                            passwordResetFeedbackColor: passwordResetFeedback?.color,
                            isSendingPasswordReset: isSendingPasswordReset,
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
                                        passwordResetFeedback = .success("Password reset link sent to \(email).")
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
                            status: AccountLegalStatus(
                                summaryText: authViewModel.acceptedTermsSummaryText,
                                acceptedAtText: authViewModel.acceptedTermsAtText,
                                isOutdated: authViewModel.isAcceptedTermsOutdated
                            ),
                            acceptedTermsVersionText: authViewModel.acceptedTermsVersionText,
                            acceptedPrivacyVersionText: authViewModel.acceptedPrivacyVersionText,
                            shouldShowAcceptLatest: authViewModel.isAcceptedTermsOutdated
                            || authViewModel.acceptedTermsSummaryText == nil,
                            isAuthenticating: isAcceptingLatestTerms,
                            feedbackMessage: legalFeedback?.message,
                            feedbackColor: legalFeedback?.color,
                            isAcceptingLatestTerms: isAcceptingLatestTerms,
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
            await authViewModel.refreshTermsAcceptance()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await authViewModel.refreshCurrentUserFromServer() }
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
