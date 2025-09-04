//
//  CreateAccountViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import Foundation

/// CreateAccountViewModel
/// ----------------------
/// Holds the **Create Account** form state, validates input, and talks to the auth service.
///
/// Policy (simple & consistent):
/// - For any email flow (new account or anonymous --> email link), we:
///   1) send a **verification email**
///   2) **sign out immediately**
/// The user verifies via email and signs in again. No in-app “unverified” state.
@MainActor
final class CreateAccountViewModel: ObservableObject {
    // MARK: - Form state
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var acceptedTerms: Bool = false

    // MARK: - UI state
    @Published var isAuthenticating: Bool = false
    @Published var hasTriedSubmit: Bool = false
    @Published private(set) var appError: AuthAppError?

    // MARK: - Dependencies
    private let service: FirebaseAuthService?
    private let onVerificationEmailSent: () -> Void

    // MARK: - Derived
    var errorMessage: String? { appError?.errorDescription }
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }
    var isPasswordValid: Bool { AuthValidator.isValidPassword(password) }
    var isPasswordMatch: Bool { !password.isEmpty && password == confirmPassword }
    var canSubmit: Bool {
        isEmailValid && isPasswordValid && isPasswordMatch && acceptedTerms && !isAuthenticating
    }

    // MARK: - Helper texts
    var emailHelperText: String? {
        hasTriedSubmit && !isEmailValid ? "Enter a valid email address" : nil
    }
    var passwordHelperText: String? {
        hasTriedSubmit && !isPasswordValid
        ? "Password must be \(AuthValidator.Policy.minLength)–\(AuthValidator.Policy.maxLength) chars and include A–Z, a–z, 0–9"
        : nil
    }
    var confirmHelperText: String? {
        (hasTriedSubmit || !confirmPassword.isEmpty) && !isPasswordMatch ? "Passwords don’t match" : nil
    }
    var termsHelperText: String? {
        !acceptedTerms && hasTriedSubmit ? "You must accept the terms to continue" : nil
    }

    // MARK: - Init
    init(
        service: FirebaseAuthService,
        onVerificationEmailSent: @escaping () -> Void
    ) {
        self.service = service
        self.onVerificationEmailSent = onVerificationEmailSent
    }

    /// Preview-only initializer (no network, static state).
    init(
        previewEmail: String = "",
        previewIsAuthenticating: Bool = false,
        previewErrorMessage: String? = nil
    ) {
        self.service = nil
        self.onVerificationEmailSent = {}
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.appError = previewErrorMessage.map { .unknown($0) }
    }

    // MARK: - Actions

    /// Submit the form.
    ///
    /// - If current user is **anonymous**: link to email/password,
    ///   then **send verification email** and **sign out**.
    /// - Else: create a new account, **send verification email**, then **sign out**.
    func submit() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard let service, canSubmit else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            if service.isAnonymous {
                _ = try await service.linkAnonymousAccount(email: email, password: password)
                try await service.resendVerificationEmail()
                try? service.signOut()
                appError = nil
                onVerificationEmailSent()
            } else {
                try await service.signUpRequiringEmailVerification(email: email, password: password)
                appError = nil
                onVerificationEmailSent()
            }
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }
}
