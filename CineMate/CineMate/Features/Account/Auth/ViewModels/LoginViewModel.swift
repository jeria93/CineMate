//
//  LoginViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation
import UIKit

/// View model for the Login screen.
/// - Holds form state and simple validation
/// - Calls FirebaseAuthService for auth actions
/// - Updates UI state (`isAuthenticating`, `appError`) on the main actor
@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Form state (bound to UI)
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI state (loading/errors)
    @Published var isAuthenticating = false
    @Published private(set) var appError: AuthAppError?
    @Published var hasTriedSubmit = false

    // MARK: - Dependencies
    private let service: FirebaseAuthService?          // nil in previews
    private let googleClient: GoogleAuthClient         // defaults to live
    private let onSuccess: (String) -> Void            // returns Firebase UID

    // MARK: - Derived UI (helpers for the view)
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
    init(
        service: FirebaseAuthService,
        googleClient: GoogleAuthClient? = nil,
        onSuccess: @escaping (String) -> Void
    ) {
        self.service = service
        self.googleClient = googleClient ?? LiveGoogleAuthClient()
        self.onSuccess = onSuccess
    }

    /// Preview-only (never touches network/SDKs).
    init(previewEmail: String = "", previewIsAuthenticating: Bool = false, previewError: String? = nil) {
        self.service = nil
        self.googleClient = PreviewGoogleAuthClient()
        self.onSuccess = { _ in }
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.appError = previewError.map { .unknown($0) }
    }

    // MARK: - Actions (Email/Password)

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

// MARK: - Google login

extension LoginViewModel {

    /// Starts Google Sign-In and completes Firebase sign-in.
    /// - Note: Ignores pure user-cancel (no error banner).
    func signInWithGoogle() async {
        guard let service else { return }
        guard let presenter = UIViewController.topMostViewController else {
            appError = .unknown("Unable to present sign-in UI.")
            return
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            let uid = try await service.signInWithGoogle(from: presenter, using: googleClient)
            appError = nil
            onSuccess(uid)
        } catch {
            let mapped = AuthAppError.mapToAppError(error)
            if !mapped.isUserCancellation { appError = mapped }
        }
    }
}
