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

    private var showEmailError: Bool {
        !createViewModel.isEmailValid &&
        (createViewModel.hasTriedSubmit || (!createViewModel.email.isEmpty && focus != .email))
    }
    private var showPasswordMismatchError: Bool {
        !createViewModel.isPasswordMatch &&
        (createViewModel.hasTriedSubmit || !createViewModel.confirmPassword.isEmpty)
    }

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
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focus = .password }

                if showEmailError {
                    Text("Enter a valid email address")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Password
                SecureField("Password", text: $createViewModel.password)
                    .textContentType(nil)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focus = .confirm }

                // Confirm
                SecureField("Confirm Password", text: $createViewModel.confirmPassword)
                    .textContentType(nil)
                    .focused($focus, equals: .confirm)
                    .submitLabel(.done)
                    .onSubmit { Task { await createTapped() } }

                if showPasswordMismatchError {
                    Text("Passwords don’t match")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Terms
                Toggle("I accept the terms and conditions", isOn: $createViewModel.acceptedTerms)

                Button("View terms") { showTerms = true }
                    .buttonStyle(.plain)
                    .font(.footnote)

                if let termsHint = createViewModel.termsHelperText {
                    Text(termsHint)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Submit
                Button {
                    Task { await createTapped() }
                } label: {
                    Text("Create Account")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!createViewModel.canSubmit)

                if let message = createViewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
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
        .animation(.default, value: createViewModel.isAuthenticating)
        .animation(.default, value: showEmailError)
        .animation(.default, value: showPasswordMismatchError)
        .animation(.default, value: createViewModel.errorMessage)
        .onAppear { focus = .email }
        .sheet(isPresented: $showTerms) {
            ScrollView {
                Text(TermsContent.previewMarkdown)
                    .padding()
                    .textSelection(.enabled)
            }
        }
    }

    private func createTapped() async {
        await createViewModel.signUp()
    }
}

#Preview("Empty") { CreateAccountView.previewEmpty.withPreviewNavigation() }
#Preview("Filled Valid") { CreateAccountView.previewFilledValid.withPreviewNavigation() }
#Preview("PassWord Mismatch") { CreateAccountView.previewPasswordMismatch.withPreviewNavigation() }
#Preview("Invalid Email") { CreateAccountView.previewInvalidEmail.withPreviewNavigation() }
#Preview("Is Authenticating") { CreateAccountView.previewIsAuthenticating.withPreviewNavigation() }
#Preview("Server Error") { CreateAccountView.previewServerError.withPreviewNavigation() }
enum TermsContent {
    static let previewMarkdown = """
    # Terms of Service (Preview)

    1. You must be 13+
    2. We store minimal data
    3. You can delete your account anytime

    This is preview text only
    """
}
