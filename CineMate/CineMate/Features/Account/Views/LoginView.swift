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

    init(viewModel: LoginViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("CineMate").font(.title2).bold()

            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .submitLabel(.next)
                .focused($focusedField, equals: .email)
                .onSubmit { focusedField = .password }
                .disabled(viewModel.isAuthenticating)
                .onChange(of: viewModel.email) { _, new in
                    let cleaned = AuthValidator.sanitizedEmail(from: new)
                    if cleaned != new { viewModel.email = cleaned }
                }

            if let hint = viewModel.emailHelperText {
                Text(hint).font(.footnote).foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit { Task { await viewModel.login() } }
                .disabled(viewModel.isAuthenticating)
                .onChange(of: viewModel.password) { _, new in
                    let cleaned = AuthValidator.sanitizedPassword(from: new)
                    if cleaned != new { viewModel.password = cleaned }
                }

            if let hint = viewModel.passwordHelperText {
                Text(hint).font(.footnote).foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

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
        .animation(.default, value: viewModel.isAuthenticating)
        .animation(.default, value: viewModel.errorMessage != nil)
    }
}

#Preview("Empty") { LoginView.previewEmpty }
#Preview("Error") { LoginView.previewError }
#Preview("Authenticating") { LoginView.previewIsAuthenticating }
