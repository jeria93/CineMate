//
//  CreateAccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import SwiftUI

/// Create account screen for both new users and guest upgrade.
struct CreateAccountView: View {
    @ObservedObject private var createViewModel: CreateAccountViewModel

    @State private var activeLegalSheet: LegalSheet?
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var confirmFocused: Bool

    init(createViewModel: CreateAccountViewModel) {
        self._createViewModel = ObservedObject(wrappedValue: createViewModel)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            AuthTheme.curtainContrastOverlay.ignoresSafeArea()

            VStack(spacing: 22) {
                AuthHeader()

                VStack(alignment: .leading, spacing: 16) {
                    // Email
                    AuthEmailField(
                        text: $createViewModel.email,
                        isDisabled: createViewModel.isAuthenticating,
                        submitLabel: .next,
                        onSubmit: {
                            emailFocused = false
                            passwordFocused = true
                        },
                        isFocused: $emailFocused
                    )
                    if let text = createViewModel.emailHelperText {
                        ValidationMessageView(message: text, palette: .curtain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Password
                    AuthPasswordField(
                        title: "Password",
                        text: $createViewModel.password,
                        isDisabled: createViewModel.isAuthenticating,
                        mode: .create,
                        submitLabel: .next,
                        onSubmit: {
                            passwordFocused = false
                            confirmFocused = true
                        },
                        isFocused: $passwordFocused
                    )
                    if let text = createViewModel.passwordHelperText {
                        ValidationMessageView(message: text, palette: .curtain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Confirm password
                    AuthPasswordField(
                        title: "Confirm Password",
                        text: $createViewModel.confirmPassword,
                        isDisabled: createViewModel.isAuthenticating,
                        mode: .create,
                        submitLabel: .done,
                        onSubmit: { Task { await createViewModel.submit() } },
                        isFocused: $confirmFocused
                    )
                    if let text = createViewModel.confirmHelperText {
                        ValidationMessageView(message: text, palette: .curtain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    legalConsentRow(
                        title: "I accept the Terms of Service",
                        linkTitle: "View terms",
                        isAccepted: $createViewModel.acceptedTerms,
                        onLinkTap: { activeLegalSheet = .terms }
                    )
                    if let text = createViewModel.termsHelperText {
                        ValidationMessageView(message: text, palette: .curtain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    legalConsentRow(
                        title: "I accept the Privacy Policy",
                        linkTitle: "View privacy policy",
                        isAccepted: $createViewModel.acceptedPrivacyPolicy,
                        onLinkTap: { activeLegalSheet = .privacyPolicy }
                    )
                    if let text = createViewModel.privacyPolicyHelperText {
                        ValidationMessageView(message: text, palette: .curtain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Submit (smart)
                    Button {
                        Task { await createViewModel.submit() }
                    } label: {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.pillWhite)
                    .controlSize(.large)
                    .frame(height: 48)
                    .disabled(!createViewModel.canSubmit)

                    // Server error
                    if let message = createViewModel.errorMessage {
                        AuthErrorBlock(message: message)
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)
            }
            .padding(.bottom, 16)

            // Loading overlay
            if createViewModel.isAuthenticating {
                LoadingView(title: "Creating account…")
                    .transition(.opacity)
            }
        }
        .tint(AuthTheme.popcorn)
        .sheet(item: $activeLegalSheet) { document in
            TermsSheet(
                markdown: document.markdown,
                title: document.title,
                subtitle: document.subtitle,
                iconSystemName: document.iconSystemName
            )
        }
        .task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            emailFocused = true
        }
        .onChange(of: createViewModel.email) { _, _ in
            createViewModel.clearError()
        }
        .onChange(of: createViewModel.password) { _, _ in
            createViewModel.clearError()
        }
        .onChange(of: createViewModel.confirmPassword) { _, _ in
            createViewModel.clearError()
        }
        .onChange(of: createViewModel.acceptedTerms) { _, _ in
            createViewModel.clearError()
        }
        .onChange(of: createViewModel.acceptedPrivacyPolicy) { _, _ in
            createViewModel.clearError()
        }
    }

    private func legalConsentRow(
        title: String,
        linkTitle: String,
        isAccepted: Binding<Bool>,
        onLinkTap: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(AuthTheme.textOnCurtainPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing, 56)
                .overlay(alignment: .trailing) {
                    Toggle("", isOn: isAccepted)
                        .labelsHidden()
                        .tint(AuthTheme.linkOnCurtain)
                        .disabled(createViewModel.isAuthenticating)
                }

            Button(linkTitle, action: onLinkTap)
                .buttonStyle(.plain)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AuthTheme.linkOnCurtain)
                .underline()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private enum LegalSheet: String, Identifiable {
        case terms
        case privacyPolicy

        var id: String { rawValue }

        var title: String {
            switch self {
            case .terms:
                return "Terms of Service"
            case .privacyPolicy:
                return "Privacy Policy"
            }
        }

        var subtitle: String {
            switch self {
            case .terms:
                return "Please review before creating an account"
            case .privacyPolicy:
                return "Please review before creating an account"
            }
        }

        var iconSystemName: String {
            switch self {
            case .terms:
                return "doc.text"
            case .privacyPolicy:
                return "lock.doc"
            }
        }

        var markdown: String {
            switch self {
            case .terms:
                return TermsContent.termsMarkdown
            case .privacyPolicy:
                return TermsContent.privacyPolicyMarkdown
            }
        }
    }
}

#Preview("Empty") { CreateAccountView.previewEmpty }
#Preview("Filled Valid") { CreateAccountView.previewFilledValid }
#Preview("Password Mismatch") { CreateAccountView.previewPasswordMismatch }
#Preview("Invalid Email") { CreateAccountView.previewInvalidEmail }
#Preview("Terms Not Accepted") { CreateAccountView.previewTermsNotAccepted }
#Preview("Is Authenticating") { CreateAccountView.previewIsAuthenticating }
#Preview("Server Error") { CreateAccountView.previewServerError }
