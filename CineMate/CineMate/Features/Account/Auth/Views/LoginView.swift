//
//  LoginView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Dependencies
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter

    // MARK: - UI State
    @State private var showResetSheet = false

    // MARK: - Focus
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

    init(viewModel: LoginViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("CineMate").font(.title2).bold()

            // Email
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

            // Actions
            HStack {
                Spacer()
                Button("Forgot password?") { showResetSheet = true }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isAuthenticating)
            }

            Button("Sign in") { Task { await viewModel.login() } }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isAuthenticating)

            Button("Continue as guest") { Task { await viewModel.continueAsGuest() } }
                .buttonStyle(.bordered)
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

            Spacer()

            HStack(spacing: 6) {
                Text("Don’t have an account?")
                Button("Register") { navigator.goToCreateAccount() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .accessibilityAddTraits(.isLink)
                    .disabled(viewModel.isAuthenticating)
            }
            .font(.footnote)
        }
        .padding()
        .task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            if viewModel.email.isEmpty {
                emailFocused = true
            } else if viewModel.password.isEmpty {
                passwordFocused = true
            }
        }
        .overlay {
            if viewModel.isAuthenticating {
                LoadingView(title: "Signing in…").transition(.opacity)
            }
        }
        .toast(toastCenter.message)
        .sheet(isPresented: $showResetSheet) {
            ResetPasswordSheet()
                .environmentObject(toastCenter)
        }
    }
}

#Preview("Empty") { LoginView.previewEmpty }
#Preview("Error") { LoginView.previewError }
#Preview("Authenticating") { LoginView.previewIsAuthenticating }
