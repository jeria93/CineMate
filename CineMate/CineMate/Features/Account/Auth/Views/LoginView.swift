//
//  LoginView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetSheet = false
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

    init(viewModel: LoginViewModel) { _viewModel = .init(wrappedValue: viewModel) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 22) {
                AuthHeader()

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

                    GoogleSignInButton(
                        scheme: colorScheme == .dark ? .dark : .light,
                        style: .standard,
                        state: viewModel.isAuthenticating ? .disabled : .normal
                    ) { Task { await viewModel.signInWithGoogle() } }
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)

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
                                await viewModel.resendVerification()
                                toastCenter.show("Verification email sent. Check your inbox")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Text("Don’t have an account?").foregroundStyle(.white.opacity(0.85))
                    Button("Register") { navigator.goToCreateAccount() }
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
        .task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            if viewModel.email.isEmpty { emailFocused = true }
            else if viewModel.password.isEmpty { passwordFocused = true }
        }
        .overlay {
            if viewModel.isAuthenticating {
                LoadingView(title: "Signing in…").transition(.opacity)
            }
        }
        .sheet(isPresented: $showResetSheet) {
            ResetPasswordSheet().environmentObject(toastCenter)
        }
        .tint(AuthTheme.popcorn)
    }
}

// MARK: - Previews

#Preview("Empty") { LoginView.previewEmpty }
#Preview("Error") { LoginView.previewError }
#Preview("Authenticating") { LoginView.previewIsAuthenticating }
