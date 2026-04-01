//
//  LoginView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI
import GoogleSignInSwift

/// Login screen for email password, Google, and guest sign in.
struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var toastCenter: ToastCenter
    @Environment(\.colorScheme) private var colorScheme
    private let onRegister: () -> Void

    @State private var showResetSheet = false
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

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

            VStack(spacing: 22) {
                loginHeader

                VStack(alignment: .leading, spacing: 16) {
                    AuthEmailField(
                        text: $viewModel.email,
                        isDisabled: viewModel.isAuthenticating,
                        submitLabel: .next,
                        onSubmit: { passwordFocused = true },
                        isFocused: $emailFocused
                    )
                    if let hint = viewModel.emailHelperText {
                        ValidationMessageView(message: hint)
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
                        ValidationMessageView(message: hint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        Spacer()
                        Button("Forgot password?") { showResetSheet = true }
                            .buttonStyle(.plain)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AuthTheme.popcorn)
                            .disabled(viewModel.isAuthenticating)
                    }

                    Button { Task { await viewModel.login() } } label: {
                        Text("Sign in").fontWeight(.semibold).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.pillWhite)
                    .controlSize(.large)
                    .frame(height: 48)
                    .disabled(viewModel.isAuthenticating)

                    OrDivider(text: "or continue with")

                    HStack {
                        Spacer()
                        GoogleSignInButton(
                            scheme: colorScheme == .dark ? .dark : .light,
                            style: .icon,
                            state: viewModel.isAuthenticating ? .disabled : .normal
                        ) { Task { await viewModel.signInWithGoogle() } }
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                            .accessibilityLabel("Sign in with Google")
                        Spacer()
                    }

                    Button {
                        Task { await viewModel.continueAsGuest() }
                    } label: {
                        Label("Continue as guest", systemImage: "person.crop.circle.badge.questionmark")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(AuthTheme.popcorn)
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
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Text("Don’t have an account?").foregroundStyle(.white.opacity(0.85))
                    Button("Register") { onRegister() }
                        .buttonStyle(.plain)
                        .foregroundStyle(AuthTheme.popcorn)
                        .accessibilityAddTraits(.isLink)
                        .disabled(viewModel.isAuthenticating)
                }
                .font(.footnote)
            }
            .padding(.top, 28)
            .padding(.bottom, 16)
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
        .onChange(of: viewModel.email) { _, _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.password) { _, _ in
            viewModel.clearError()
        }
        .tint(AuthTheme.popcorn)
    }

    @ViewBuilder
    private var loginHeader: some View {
#if DEBUG
        AuthHeader(onIconLongPress: applyDebugCredentials)
#else
        AuthHeader()
#endif
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
