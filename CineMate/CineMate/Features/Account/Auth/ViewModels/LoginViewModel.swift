//
//  LoginViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation

/// View model for the Login screen.
/// Holds form state, runs validation, and calls FirebaseAuthService.
/// UI-only logic, no navigation.
@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Form state
    @Published var email = ""          // user email input
    @Published var password = ""       // user password input

    // MARK: - UI state
    @Published var isAuthenticating = false   // show spinner / disable inputs
    @Published private(set) var appError: AuthAppError?   // last error
    @Published var hasTriedSubmit = false    // used to show helper texts

    // MARK: - Dependencies
    private let service: FirebaseAuthService?    // nil in previews
    private let onSuccess: (String) -> Void      // callback with UID

    // MARK: - Derived UI
    var errorMessage: String? { appError?.errorDescription }
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }
    var isPasswordValid: Bool { AuthValidator.isValidPassword(password) }
    var canSubmit: Bool { isEmailValid && isPasswordValid && !isAuthenticating }

    var emailHelperText: String? {
        hasTriedSubmit && !isEmailValid ? "Enter a valid email address" : nil
    }
    var passwordHelperText: String? {
        hasTriedSubmit && !isPasswordValid
        ? "Password must be \(AuthValidator.Policy.minLength)–\(AuthValidator.Policy.maxLength) chars and include A–Z, a–z, 0–9"
        : nil
    }
    var shouldOfferResendVerification: Bool { appError == .emailNotVerified }

    // MARK: - Init
    init(service: FirebaseAuthService, onSuccess: @escaping (String) -> Void) {
        self.service = service
               self.onSuccess = onSuccess
    }

    /// Preview-only init (no network).
    init(previewEmail: String = "", previewIsAuthenticating: Bool = false, previewError: String? = nil) {
        self.service = nil
        self.onSuccess = { _ in }
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.appError = previewError.map { .unknown($0) }
    }

    // MARK: - Actions

    /// Try login with email/password.
    func login() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard canSubmit, let service else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signIn(email: email, password: password)
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    /// Try create account (immediate sign-in).
    func signUp() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard canSubmit, let service else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signUp(email: email, password: password)
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    /// Send reset password email.
    func resetPassword() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        guard isEmailValid, let service else { return }

        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            try await service.sendPasswordReset(email: email)
            appError = nil
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    /// Re-send email verification.
    func resendVerification() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            try await service.resendVerificationEmail()
            appError = nil
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    /// Sign in anonymously as guest.
    func continueAsGuest() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signInAnonymously()
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }
}
