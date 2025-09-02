//
//  CreateAccountViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import Foundation

/// # CreateAccountViewModel
/// Holds the **Create Account** form state, validates input, and calls the auth service.
///
/// How submit works:
/// - If the current Firebase user is **anonymous** -> we **link/upgrade** the account (keeps the user signed in).
/// - Otherwise -> we create a **new account**, **send a verification email**, and the service signs out.
///
/// Notes:
/// - This type is `@MainActor` so all published changes are UI-safe.
/// - Preview initializer never touches the network.
@MainActor
final class CreateAccountViewModel: ObservableObject {
    // MARK: - Form state
    /// User's email input.
    @Published var email: String = ""
    /// User's password input.
    @Published var password: String = ""
    /// Repeat password input.
    @Published var confirmPassword: String = ""
    /// Must be true before submitting.
    @Published var acceptedTerms: Bool = false

    // MARK: - UI state
    /// True while a submit is in progress.
    @Published var isAuthenticating: Bool = false
    /// Set to true after the first submit attempt (enables helper texts).
    @Published var hasTriedSubmit: Bool = false
    /// App-friendly error to show in the UI (nil = OK).
    @Published private(set) var appError: AuthAppError?

    // MARK: - Dependencies
    /// Backend auth service (nil in previews).
    private let service: FirebaseAuthService?
    /// Called after **verification email** is sent on normal sign-up.
    private let onVerificationEmailSent: () -> Void
    /// Called after **anonymous -> email/password** upgrade succeeds.
    private let onUpgraded: () -> Void

    // MARK: - Derived
    /// Localized error text for the view.
    var errorMessage: String? { appError?.errorDescription }
    /// Client-side checks.
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }
    var isPasswordValid: Bool { AuthValidator.isValidPassword(password) }
    var isPasswordMatch: Bool { !password.isEmpty && password == confirmPassword }

    /// Button enablement.
    var canSubmit: Bool {
        isEmailValid && isPasswordValid && isPasswordMatch && acceptedTerms && !isAuthenticating
    }

    // MARK: - Helper texts (shown after first submit or when useful)
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
        onVerificationEmailSent: @escaping () -> Void,
        onUpgraded: @escaping () -> Void
    ) {
        self.service = service
        self.onVerificationEmailSent = onVerificationEmailSent
        self.onUpgraded = onUpgraded
    }

    /// Preview-only init (no network, static state).
    init(
        previewEmail: String = "",
        previewIsAuthenticating: Bool = false,
        previewErrorMessage: String? = nil
    ) {
        self.service = nil
        self.onVerificationEmailSent = {}
        self.onUpgraded = {}
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.appError = previewErrorMessage.map { .unknown($0) }
    }

    // MARK: - Actions

    /// Submit the form.
    /// Steps:
    /// 1) Mark that we tried to submit and sanitize the email.
    /// 2) If the form is valid, call the right auth flow:
    ///    - `service.isAnonymous == true` -> link the anonymous user (upgrade).
    ///    - else -> sign up, send verification email, and sign out (handled by the service).
    /// 3) Map any backend error to `AuthAppError`.
    func submit() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard let service, canSubmit else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            if service.isAnonymous {
                _ = try await service.linkAnonymousAccount(email: email, password: password)
                appError = nil
                onUpgraded()
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
