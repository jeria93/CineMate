//
//  CreateAccountViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import Foundation

/// View model for the Create Account screen.
/// Holds form state, runs client-side validation, and talks to the auth service.
@MainActor
final class CreateAccountViewModel: ObservableObject {
    // MARK: - Form state
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var acceptedTerms: Bool = false

    // MARK: - UI state
    @Published var isAuthenticating: Bool = false
    /// Set on first submit attempt; enables helper texts.
    @Published var hasTriedSubmit: Bool = false
    /// App-friendly auth error for the screen (read-only to views).
    @Published private(set) var appError: AuthAppError?

    // MARK: - Dependencies
    /// Auth backend (nil in previews).
    private let service: FirebaseAuthService?
    /// Callback after verification email is sent.
    private let onVerificationEmailSent: () -> Void

    // MARK: - Derived UI & validation
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
    init(service: FirebaseAuthService, onVerificationEmailSent: @escaping () -> Void) {
        self.service = service
        self.onVerificationEmailSent = onVerificationEmailSent
    }

    /// Preview-only initializer (no network).
    init(previewEmail: String = "", previewIsAuthenticating: Bool = false, previewErrorMessage: String? = nil) {
        self.service = nil
        self.onVerificationEmailSent = {}
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.appError = previewErrorMessage.map { .unknown($0) }
    }

    // MARK: - Actions
    /// Create account and send verification email (sanitizes email, maps errors).
    func signUp() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)

        guard let service, canSubmit else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            try await service.signUpRequiringEmailVerification(email: email, password: password)
            appError = nil
            onVerificationEmailSent()
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    /// Link an anonymous account to email/password (upgrade guest).
    func upgradeAnonymousAccount() async {
        email = AuthValidator.sanitizedEmail(from: email)
        guard let service, isEmailValid else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            _ = try await service.linkAnonymousAccount(email: email, password: password)
            appError = nil
            onVerificationEmailSent()
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }
}
