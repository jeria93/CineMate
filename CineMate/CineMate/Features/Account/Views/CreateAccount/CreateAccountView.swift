//
//  CreateAccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject private var createViewModel: CreateAccountViewModel

    private enum Field { case email, password, confirm }
    @FocusState private var focus: Field?
    @State private var showTerms = false

    init(createViewModel: CreateAccountViewModel) {
        self._createViewModel = ObservedObject(wrappedValue: createViewModel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Email
                TextField("Email", text: $createViewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focus = .password }
                    .onChange(of: createViewModel.email) { _, new in
                        let cleaned = AuthValidator.sanitizedEmail(from: new)
                        if cleaned != new { createViewModel.email = cleaned }
                    }

                if let text = createViewModel.emailHelperText, focus != .email {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // Password (disable strong-password UI)
                SecureField("Password", text: $createViewModel.password)
                    .textContentType(nil)
                    .textFieldStyle(.roundedBorder)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focus = .confirm }
                    .onChange(of: createViewModel.password) { _, new in
                        let cleaned = AuthValidator.sanitizedPassword(from: new)
                        if cleaned != new { createViewModel.password = cleaned }
                    }

                if let text = createViewModel.passwordHelperText, focus != .password {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                SecureField("Confirm Password", text: $createViewModel.confirmPassword)
                    .textContentType(nil)
                    .textFieldStyle(.roundedBorder)
                    .focused($focus, equals: .confirm)
                    .submitLabel(.done)
                    .onSubmit { Task { await createViewModel.signUp() } }
                    .onChange(of: createViewModel.confirmPassword) { _, new in
                        let cleaned = AuthValidator.sanitizedPassword(from: new)
                        if cleaned != new { createViewModel.confirmPassword = cleaned }
                    }

                if let text = createViewModel.confirmHelperText, focus != .confirm {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // Terms
                Toggle("I accept the terms and conditions", isOn: $createViewModel.acceptedTerms)

                Button("View terms") { showTerms = true }
                    .buttonStyle(.plain)
                    .font(.footnote)

                if let text = createViewModel.termsHelperText {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // Submit
                Button("Create Account") { Task { await createViewModel.signUp() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(!createViewModel.canSubmit)

                // Server error
                if let message = createViewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
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
        .animation(.default, value: createViewModel.isAuthenticating)
        .animation(.default, value: createViewModel.emailHelperText != nil)
        .animation(.default, value: createViewModel.passwordHelperText != nil)
        .animation(.default, value: createViewModel.confirmHelperText != nil)
        .animation(.default, value: createViewModel.errorMessage)
        .onAppear { focus = .email }
        .sheet(isPresented: $showTerms) {
            ScrollView {
                Text(TermsContent.termsMarkdown)
                    .padding()
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview("Empty") { CreateAccountView.previewEmpty }
#Preview("Filled Valid") { CreateAccountView.previewFilledValid }
#Preview("Password Mismatch") { CreateAccountView.previewPasswordMismatch }
#Preview("Invalid Email") { CreateAccountView.previewInvalidEmail }
#Preview("Is Authenticating") { CreateAccountView.previewIsAuthenticating }
#Preview("Server Error") { CreateAccountView.previewServerError }
