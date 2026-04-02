//
//  LoginViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation
import UIKit

/// View model for LoginView.
/// Handles login form state, loading, and errors.
@MainActor
final class LoginViewModel: ObservableObject {

    enum Action {
        case emailPassword
        case google
        case guest
        case resendVerification

        var loadingTitle: String {
            switch self {
            case .emailPassword: "Signing in..."
            case .google: "Signing in with Google..."
            case .guest: "Starting guest session..."
            case .resendVerification: "Sending verification email..."
            }
        }
    }

    // MARK: - Form state (bound to UI)
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI state (loading/errors)
    @Published var isAuthenticating = false
    @Published private(set) var appError: AuthAppError?
    @Published var hasTriedSubmit = false
    @Published private(set) var activeAction: Action?

    // MARK: - Dependencies
    private let service: FirebaseAuthService?          // nil in previews
    private let googleClient: GoogleAuthClient         // defaults to live
    private let onSuccess: (String) -> Void            // returns Firebase UID

    // MARK: - Derived UI (helpers for the view)
    var errorMessage: String? { appError?.errorDescription }
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }
    var isPasswordValid: Bool { AuthValidator.isValidLoginPassword(password) }
    var canSubmit: Bool { isEmailValid && isPasswordValid && !isAuthenticating }
    var emailHelperText: String? { AuthValidator.emailHelperText(email: email, hasTriedSubmit: hasTriedSubmit) }
    var passwordHelperText: String? { AuthValidator.loginPasswordHelperText(password: password, hasTriedSubmit: hasTriedSubmit) }
    var shouldOfferResendVerification: Bool { appError == .emailNotVerified }
    var loadingTitle: String { activeAction?.loadingTitle ?? "Authenticating..." }

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

    /// Preview init.
    /// Uses preview client and no live service.
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

        startAction(.emailPassword)
        defer { finishAction() }
        do {
            let uid = try await service.signIn(email: email, password: password)
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    @discardableResult
    func resendVerification() async -> Bool {
        guard let service else { return false }
        email = AuthValidator.sanitizedEmail(from: email)
        password = AuthValidator.sanitizedPassword(from: password)
        guard !email.isEmpty, !password.isEmpty else {
            appError = .invalidCredentials
            return false
        }

        startAction(.resendVerification)
        defer { finishAction() }
        do {
            try await service.resendVerificationEmail(email: email, password: password)
            appError = nil
            return true
        } catch {
            appError = AuthAppError.mapToAppError(error)
            return false
        }
    }

    func continueAsGuest() async {
        guard let service else { return }
        startAction(.guest)
        defer { finishAction() }
        do {
            let uid = try await service.signInAnonymously()
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    func clearError() {
        appError = nil
    }

    private func startAction(_ action: Action) {
        activeAction = action
        isAuthenticating = true
    }

    private func finishAction() {
        activeAction = nil
        isAuthenticating = false
    }
}

// MARK: - Google login

extension LoginViewModel {

    /// Runs Google sign in flow.
    /// User cancel does not show an error.
    func signInWithGoogle() async {
        guard let service else { return }
        guard let presenter = UIViewController.topMostViewController else {
            appError = .unknown("Unable to present sign-in UI.")
            return
        }

        startAction(.google)
        defer { finishAction() }

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
