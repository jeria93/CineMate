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

    @FocusState private var focusedField: Field?
    private enum Field { case email, password }

    private var isEmailValid: Bool {
        viewModel.email.contains("@") && viewModel.email.contains(".")
    }
    private var isPasswordValid: Bool { viewModel.password.count >= 6 }
    private var isFormValid: Bool { isEmailValid && isPasswordValid }

    init(viewModel: LoginViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("CineMate")
                .font(.title2)
                .bold()

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

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit { Task { await signInTapped() } }
                .disabled(viewModel.isAuthenticating)

            Button("Sign in") { Task { await signInTapped() } }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isAuthenticating || !isFormValid)

            Button("Forgot password?") {
                Task { await viewModel.resetPassword() }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isAuthenticating)

            Button("Continue as guest") {
                Task { await viewModel.continueAsGuest() }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isAuthenticating)

            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("Don’t have an account?")
                Button("Register") {
                    navigator.goToCreateAccount()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .accessibilityAddTraits(.isLink)
            }
            .font(.footnote)
        }
        .padding()
        .overlay {
            if viewModel.isAuthenticating {
                LoadingView(title: "Signing in…")
                    .transition(.opacity)
            }
        }
        .onAppear { focusedField = .email }
    }

    // MARK: - Actions

    private func signInTapped() async {
        await viewModel.login()
    }

    private func signUpTapped() async {
        await viewModel.signUp()
    }
}

#Preview("Empty") {
    LoginView.previewEmpty.withPreviewNavigation()
}

#Preview("Filled") {
    LoginView.previewFilled.withPreviewNavigation()
}

#Preview("Error") {
    LoginView.previewError.withPreviewNavigation()
}

#Preview("Is Authenticating") {
    LoginView.previewIsAuthenticating.withPreviewNavigation()
}
