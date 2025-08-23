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

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    init(createViewModel: CreateAccountViewModel) {
        self._createViewModel = ObservedObject(wrappedValue: createViewModel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {

                // MARK: Email
                let emailIcons: [TrailingIcon] =
                (!createViewModel.email.isEmpty && !createViewModel.isAuthenticating)
                ? [
                    TrailingIcon(
                        systemName: "xmark.circle.fill",
                        isEnabled: true,
                        accessibilityLabel: "Clear email"
                    ) {
                        createViewModel.email = ""
                        focus = .email
                    }
                ]
                : []

                RoundedField(icons: emailIcons) {
                    TextField("Email", text: $createViewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }
                        .onChange(of: createViewModel.email) { _, new in
                            let cleaned = AuthValidator.sanitizedEmail(from: new)
                            if cleaned != new { createViewModel.email = cleaned }
                        }
                        .disabled(createViewModel.isAuthenticating)
                }

                if let text = createViewModel.emailHelperText, focus != .email {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // MARK: Password
                let passwordHasText = !createViewModel.password.isEmpty
                let passwordIcons: [TrailingIcon] =
                (passwordHasText && !createViewModel.isAuthenticating)
                ? [
                    TrailingIcon(
                        systemName: "xmark.circle.fill",
                        isEnabled: true,
                        accessibilityLabel: "Clear password"
                    ) {
                        createViewModel.password = ""
                        focus = .password
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
                            TextField("Password", text: $createViewModel.password)
                                .textContentType(.password)
                        } else {
                            SecureField("Password", text: $createViewModel.password)
                                .textContentType(nil) // stänger starkt-lösenord-UI
                        }
                    }
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focus = .confirm }
                    .onChange(of: createViewModel.password) { _, new in
                        let cleaned = AuthValidator.sanitizedPassword(from: new)
                        if cleaned != new { createViewModel.password = cleaned }
                    }
                    .disabled(createViewModel.isAuthenticating)
                }

                if let text = createViewModel.passwordHelperText, focus != .password {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // MARK: Confirm Password
                let confirmHasText = !createViewModel.confirmPassword.isEmpty
                let confirmIcons: [TrailingIcon] =
                (confirmHasText && !createViewModel.isAuthenticating)
                ? [
                    TrailingIcon(
                        systemName: "xmark.circle.fill",
                        isEnabled: true,
                        accessibilityLabel: "Clear password confirmation"
                    ) {
                        createViewModel.confirmPassword = ""
                        focus = .confirm
                    },
                    TrailingIcon(
                        systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill",
                        isEnabled: true,
                        accessibilityLabel: showConfirmPassword ? "Hide password" : "Show password"
                    ) {
                        showConfirmPassword.toggle()
                    }
                ]
                : []

                RoundedField(icons: confirmIcons) {
                    Group {
                        if showConfirmPassword {
                            TextField("Confirm Password", text: $createViewModel.confirmPassword)
                                .textContentType(.password)
                        } else {
                            SecureField("Confirm Password", text: $createViewModel.confirmPassword)
                                .textContentType(nil)
                        }
                    }
                    .focused($focus, equals: .confirm)
                    .submitLabel(.done)
                    .onSubmit { Task { await createViewModel.signUp() } }
                    .onChange(of: createViewModel.confirmPassword) { _, new in
                        let cleaned = AuthValidator.sanitizedPassword(from: new)
                        if cleaned != new { createViewModel.confirmPassword = cleaned }
                    }
                    .disabled(createViewModel.isAuthenticating)
                }

                if let text = createViewModel.confirmHelperText, focus != .confirm {
                    Text(text)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                // MARK: Terms
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

                // MARK: Submit
                Button("Create Account") { Task { await createViewModel.signUp() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(!createViewModel.canSubmit)

                // MARK: Server error
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
        .animation(.default, value: !createViewModel.email.isEmpty)
        .animation(.default, value: !createViewModel.password.isEmpty)
        .animation(.default, value: !createViewModel.confirmPassword.isEmpty)
        .animation(.default, value: createViewModel.isAuthenticating)
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
