//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Account container that orchestrates account sections, sheets, and async auth actions.
/// Child section views stay presentation-focused while this view owns navigation and toast flows.
struct AccountView: View {
    @ObservedObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject var toastCenter: ToastCenter
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingChangeEmailSheet = false
    @State private var isShowingTermsSheet = false
    
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
                            canChangeEmail: authViewModel.canChangeEmail,
                            canSendPasswordReset: authViewModel.canSendPasswordReset,
                            isAuthenticating: authViewModel.isAuthenticating,
                            onChangeEmail: {
                                isShowingChangeEmailSheet = true
                            },
                            onChangePassword: {
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
                        )
                        
                        AccountLegalSectionView(
                            summaryText: authViewModel.acceptedTermsSummaryText,
                            shouldShowAcceptLatest: authViewModel.isAcceptedTermsOutdated
                            || authViewModel.acceptedTermsSummaryText == nil,
                            isAuthenticating: authViewModel.isAuthenticating,
                            onViewTerms: {
                                isShowingTermsSheet = true
                            },
                            onAcceptLatest: {
                                Task {
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
