//
//  CreateAccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import SwiftUI

struct CreateAccountView: View {
    // MARK: - Dependencies
    @ObservedObject private var createViewModel: CreateAccountViewModel

    // MARK: - UI State
    @State private var showTerms = false

    // MARK: - Focus
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var confirmFocused: Bool

    init(createViewModel: CreateAccountViewModel) {
        self._createViewModel = ObservedObject(wrappedValue: createViewModel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {

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
                    ValidationMessageView(message: text)
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
                    ValidationMessageView(message: text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Confirm password
                AuthPasswordField(
                    title: "Confirm Password",
                    text: $createViewModel.confirmPassword,
                    isDisabled: createViewModel.isAuthenticating,
                    mode: .create,
                    submitLabel: .done,
                    onSubmit: { Task { await createViewModel.signUp() } },
                    isFocused: $confirmFocused
                )
                if let text = createViewModel.confirmHelperText {
                    ValidationMessageView(message: text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Terms
                Toggle("I accept the terms and conditions",
                       isOn: $createViewModel.acceptedTerms)
                .disabled(createViewModel.isAuthenticating)

                Button("View terms") { showTerms = true }
                    .buttonStyle(.plain)
                    .font(.footnote)

                if let text = createViewModel.termsHelperText {
                    ValidationMessageView(message: text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Submit
                Button("Create Account") { Task { await createViewModel.signUp() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(!createViewModel.canSubmit)

                // Server error
                if let message = createViewModel.errorMessage {
                    ValidationMessageView(message: message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()

            if createViewModel.isAuthenticating {
                LoadingView(title: "Creating account…")
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(!createViewModel.isAuthenticating)
        .sheet(isPresented: $showTerms) {
            ScrollView {
                Text(TermsContent.termsMarkdown)
                    .padding()
                    .textSelection(.enabled)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            emailFocused = true
        }
    }
}

#Preview("Empty") { CreateAccountView.previewEmpty }
#Preview("Filled Valid") { CreateAccountView.previewFilledValid }
#Preview("Password Mismatch") { CreateAccountView.previewPasswordMismatch }
#Preview("Invalid Email") { CreateAccountView.previewInvalidEmail }
#Preview("Is Authenticating") { CreateAccountView.previewIsAuthenticating }
#Preview("Server Error") { CreateAccountView.previewServerError }
