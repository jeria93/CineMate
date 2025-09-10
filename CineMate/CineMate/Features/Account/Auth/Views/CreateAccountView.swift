//
//  CreateAccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject private var createViewModel: CreateAccountViewModel

    @State private var showTerms = false
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
                        onSubmit: { Task { await createViewModel.submit() } },
                        isFocused: $confirmFocused
                    )
                    if let text = createViewModel.confirmHelperText {
                        ValidationMessageView(message: text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("I accept the terms and conditions")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(AuthTheme.popcorn)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.trailing, 56)
                            .overlay(alignment: .trailing) {
                                Toggle("", isOn: $createViewModel.acceptedTerms)
                                    .labelsHidden()
                                    .tint(AuthTheme.popcorn)
                                    .disabled(createViewModel.isAuthenticating)
                            }

                        Button("View terms") {
                            showTerms = true
                        }
                        .buttonStyle(.plain)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AuthTheme.popcorn)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    if let text = createViewModel.termsHelperText {
                        ValidationMessageView(message: text)
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
                        ValidationMessageView(message: message)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
        .sheet(isPresented: $showTerms) {
            TermsSheet(markdown: TermsContent.termsMarkdown)
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
