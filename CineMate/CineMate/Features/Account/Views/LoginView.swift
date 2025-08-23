//
//  LoginView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @FocusState private var focusedField: Field?
    private enum Field { case email, password }

    @State private var showPassword = false

    init(viewModel: LoginViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("CineMate").font(.title2).bold()

            // MARK: Email
            let emailIcons: [TrailingIcon] =
            (!viewModel.email.isEmpty && !viewModel.isAuthenticating)
            ? [
                TrailingIcon(
                    systemName: "xmark.circle.fill",
                    isEnabled: true,
                    accessibilityLabel: "Clear email"
                ) {
                    viewModel.email = ""
                    focusedField = .email
                }
            ]
            : []

            RoundedField(icons: emailIcons) {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .onChange(of: viewModel.email) { _, new in
                        let cleaned = AuthValidator.sanitizedEmail(from: new)
                        if cleaned != new { viewModel.email = cleaned }
                    }
                    .disabled(viewModel.isAuthenticating)
            }

            if let hint = viewModel.emailHelperText {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            // MARK: Password
            let passwordHasText = !viewModel.password.isEmpty
            let passwordIcons: [TrailingIcon] =
            (passwordHasText && !viewModel.isAuthenticating)
            ? [
                TrailingIcon(
                    systemName: "xmark.circle.fill",
                    isEnabled: true,
                    accessibilityLabel: "Clear password"
                ) {
                    viewModel.password = ""
                    focusedField = .password
                },
                TrailingIcon(
                    systemName: showPassword ? "eye.slash.fill" : "eye.fill",
                    isEnabled: true,
                    accessibilityLabel: showPassword ? "Hide password" : "Show password"
                ) {
                    showPassword.toggle()
                }
            ]
            : []

            RoundedField(icons: passwordIcons) {
                Group {
                    if showPassword {
                        TextField("Password", text: $viewModel.password)
                            .textContentType(.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.password)
                    }
                }
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { Task { await viewModel.login() } }
                .onChange(of: viewModel.password) { _, new in
                    let cleaned = AuthValidator.sanitizedPassword(from: new)
                    if cleaned != new { viewModel.password = cleaned }
                }
                .disabled(viewModel.isAuthenticating)
            }

            if let hint = viewModel.passwordHelperText {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            // MARK: Actions
            Button("Sign in") { Task { await viewModel.login() } }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)

            Button("Forgot password?") { Task { await viewModel.resetPassword() } }
                .buttonStyle(.plain)
                .disabled(viewModel.isAuthenticating)

            Button("Continue as guest") { Task { await viewModel.continueAsGuest() } }
                .buttonStyle(.bordered)
                .disabled(viewModel.isAuthenticating)

            if let message = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)

                    if viewModel.shouldOfferResendVerification {
                        Button("Resend verification email") {
                            Task {
                                await viewModel.resendVerification()
                                toastCenter.show("Verification email sent. Check your inbox")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .transition(.opacity)
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
        .overlay {
            if viewModel.isAuthenticating {
                LoadingView(title: "Signing in…").transition(.opacity)
            }
        }
        .toast(toastCenter.message)
        .onAppear { focusedField = .email }
        .animation(.default, value: !viewModel.email.isEmpty)
        .animation(.default, value: !viewModel.password.isEmpty)
        .animation(.default, value: viewModel.isAuthenticating)
        .animation(.default, value: viewModel.errorMessage != nil)
    }
}

#Preview("Empty") { LoginView.previewEmpty }
#Preview("Error") { LoginView.previewError }
#Preview("Authenticating") { LoginView.previewIsAuthenticating }
