//
//  LoginView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI
import GoogleSignInSwift

/// Sign in screen for email, Google, and guest access.
struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var toastCenter: ToastCenter
    @Environment(\.colorScheme) private var colorScheme
    private let onRegister: () -> Void
    
    @State private var showResetSheet = false
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    private let authProviderButtonSize: CGFloat = 48
    private let authProviderCornerRadius: CGFloat = 12
    private let contentMaxWidth: CGFloat = 380
    
    init(
        viewModel: LoginViewModel,
        onRegister: @escaping () -> Void = {}
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        self.onRegister = onRegister
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            AuthTheme.curtainContrastOverlay.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    loginHeader
                        .padding(.top, 12)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        AuthEmailField(
                            text: $viewModel.email,
                            isDisabled: viewModel.isAuthenticating,
                            submitLabel: .next,
                            onSubmit: { passwordFocused = true },
                            isFocused: $emailFocused
                        )
                        if let hint = viewModel.emailHelperText {
                            ValidationMessageView(message: hint, palette: .curtain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        AuthPasswordField(
                            text: $viewModel.password,
                            isDisabled: viewModel.isAuthenticating,
                            mode: .login,
                            submitLabel: .go,
                            onSubmit: { Task { await viewModel.login() } },
                            isFocused: $passwordFocused
                        )
                        if let hint = viewModel.passwordHelperText {
                            ValidationMessageView(message: hint, palette: .curtain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button("Forgot password?") { showResetSheet = true }
                            .buttonStyle(.plain)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AuthTheme.linkOnCurtain)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .disabled(viewModel.isAuthenticating)
                        
                        Button { Task { await viewModel.login() } } label: {
                            Text("Sign in").fontWeight(.semibold).frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.pillWhite)
                        .controlSize(.large)
                        .frame(height: 48)
                        .disabled(viewModel.isAuthenticating)
                        
                        if let message = viewModel.errorMessage {
                            AuthErrorBlock(
                                message: message,
                                showResend: viewModel.shouldOfferResendVerification
                            ) {
                                Task {
                                    if await viewModel.resendVerification() {
                                        toastCenter.show("Verification email sent. Check your inbox")
                                    } else if let error = viewModel.errorMessage {
                                        toastCenter.show(error)
                                    }
                                }
                            }
                        }
                        
                        OrDivider(text: "or continue with")
                        
                        HStack(spacing: 16) {
                            GoogleSignInButton(
                                scheme: colorScheme == .dark ? .dark : .light,
                                style: .icon,
                                state: viewModel.isAuthenticating ? .disabled : .normal
                            ) { Task { await viewModel.signInWithGoogle() } }
                                .frame(width: authProviderButtonSize, height: authProviderButtonSize)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: authProviderCornerRadius,
                                        style: .continuous
                                    )
                                )
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                                .accessibilityLabel("Sign in with Google")
                            
                            Button {
                                Task { await viewModel.continueAsGuest() }
                            } label: {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.tmdbNavy)
                                    .frame(width: authProviderButtonSize, height: authProviderButtonSize)
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: authProviderCornerRadius,
                                            style: .continuous
                                        )
                                        .fill(Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(
                                            cornerRadius: authProviderCornerRadius,
                                            style: .continuous
                                        )
                                        .stroke(Color.white.opacity(0.78), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                            }
                            .buttonStyle(.plain)
                            .frame(width: authProviderButtonSize, height: authProviderButtonSize)
                            .disabled(viewModel.isAuthenticating)
                            .accessibilityLabel("Continue as guest")
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Use Google for your account, or continue as guest without signing up.")
                            .font(.caption)
                            .foregroundStyle(AuthTheme.textOnCurtainSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .padding(.horizontal, 20)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            emailFocused = false
            passwordFocused = false
        }
        .overlay {
            if viewModel.isAuthenticating {
                LoadingView(title: viewModel.loadingTitle).transition(.opacity)
            }
        }
        .sheet(isPresented: $showResetSheet) {
            ResetPasswordSheet().environmentObject(toastCenter)
        }
        .sheet(isPresented: $viewModel.isGoogleLegalAcceptanceRequired) {
            GoogleLegalAcceptanceSheet(viewModel: viewModel)
                .interactiveDismissDisabled()
        }
        .onChange(of: viewModel.email) { _, _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.password) { _, _ in
            viewModel.clearError()
        }
        .tint(AuthTheme.popcorn)
        .safeAreaInset(edge: .bottom) {
            registerPrompt
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
    }
    
    @ViewBuilder
    private var loginHeader: some View {
#if DEBUG
        AuthHeader(onIconLongPress: applyDebugCredentials)
#else
        AuthHeader()
#endif
    }
    
    private var registerPrompt: some View {
        HStack(spacing: 6) {
            Text("Don’t have an account?")
                .foregroundStyle(AuthTheme.textOnCurtainSecondary)
            Button("Register") { onRegister() }
                .buttonStyle(.plain)
                .foregroundStyle(AuthTheme.linkOnCurtain)
                .underline()
                .accessibilityAddTraits(.isLink)
                .disabled(viewModel.isAuthenticating)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }
    
#if DEBUG
    private func applyDebugCredentials() {
        guard let email = DebugLoginCredentials.email,
              let password = DebugLoginCredentials.password else {
            toastCenter.show("Set DEBUG_LOGIN_EMAIL and DEBUG_LOGIN_PASSWORD in Run scheme")
            return
        }
        viewModel.email = email
        viewModel.password = password
        viewModel.hasTriedSubmit = false
        viewModel.clearError()
        emailFocused = false
        passwordFocused = false
        toastCenter.show("Debug credentials applied")
    }
#endif
}

// MARK: - Previews

#Preview("Empty") { LoginView.previewEmpty }
#Preview("Filled") { LoginView.previewFilled }
#Preview("Error") { LoginView.previewError }
#Preview("Authenticating") { LoginView.previewIsAuthenticating }

private struct GoogleLegalAcceptanceSheet: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var activeLegalSheet: LegalSheet?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(AuthTheme.popcorn)
                    Text("Review before continuing")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AuthTheme.textOnCurtainPrimary)
                    Text("Accept the same terms and privacy policy used for email accounts to finish Google sign-in.")
                        .font(.callout)
                        .foregroundStyle(AuthTheme.textOnCurtainSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                legalConsentRow(
                    title: "I accept the Terms of Service",
                    linkTitle: "View terms",
                    isAccepted: $viewModel.acceptedGoogleTerms,
                    helperText: viewModel.googleTermsHelperText,
                    onLinkTap: { activeLegalSheet = .terms }
                )

                legalConsentRow(
                    title: "I accept the Privacy Policy",
                    linkTitle: "View privacy policy",
                    isAccepted: $viewModel.acceptedGooglePrivacyPolicy,
                    helperText: viewModel.googlePrivacyPolicyHelperText,
                    onLinkTap: { activeLegalSheet = .privacyPolicy }
                )

                if let message = viewModel.errorMessage {
                    AuthErrorBlock(message: message)
                }

                Button {
                    Task { await viewModel.acceptGoogleLegalTerms() }
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.pillWhite)
                .controlSize(.large)
                .frame(height: 48)
                .disabled(viewModel.isAuthenticating)

                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .overlay {
                if viewModel.isAuthenticating {
                    LoadingView(title: viewModel.loadingTitle).transition(.opacity)
                }
            }
            .sheet(item: $activeLegalSheet) { document in
                TermsSheet(
                    markdown: document.markdown,
                    title: document.title,
                    subtitle: "Please review before continuing",
                    iconSystemName: document.iconSystemName
                )
            }
            .onChange(of: viewModel.acceptedGoogleTerms) { _, _ in
                viewModel.clearGoogleLegalError()
            }
            .onChange(of: viewModel.acceptedGooglePrivacyPolicy) { _, _ in
                viewModel.clearGoogleLegalError()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelGoogleLegalAcceptance()
                    }
                    .disabled(viewModel.isAuthenticating)
                }
            }
        }
    }

    private func legalConsentRow(
        title: String,
        linkTitle: String,
        isAccepted: Binding<Bool>,
        helperText: String?,
        onLinkTap: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AuthTheme.textOnCurtainPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("", isOn: isAccepted)
                    .labelsHidden()
                    .tint(AuthTheme.linkOnCurtain)
                    .disabled(viewModel.isAuthenticating)
            }

            Button(linkTitle, action: onLinkTap)
                .buttonStyle(.plain)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AuthTheme.linkOnCurtain)
                .underline()
                .frame(maxWidth: .infinity, alignment: .leading)

            if let helperText {
                ValidationMessageView(message: helperText, palette: .curtain)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private enum LegalSheet: String, Identifiable {
        case terms
        case privacyPolicy

        var id: String { rawValue }

        var title: String {
            switch self {
            case .terms: "Terms of Service"
            case .privacyPolicy: "Privacy Policy"
            }
        }

        var iconSystemName: String {
            switch self {
            case .terms: "doc.text"
            case .privacyPolicy: "lock.doc"
            }
        }

        var markdown: String {
            switch self {
            case .terms: TermsContent.termsMarkdown
            case .privacyPolicy: TermsContent.privacyPolicyMarkdown
            }
        }
    }
}

#if DEBUG
private enum DebugLoginCredentials {
    private static let environment = ProcessInfo.processInfo.environment
    
    static var email: String? { sanitize(environment["DEBUG_LOGIN_EMAIL"]) }
    static var password: String? { sanitize(environment["DEBUG_LOGIN_PASSWORD"]) }
    
    private static func sanitize(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
#endif
