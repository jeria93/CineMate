//
//  LoginViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation
import UIKit

/// State and actions for the login screen.
@MainActor
final class LoginViewModel: ObservableObject {

    enum Action {
        case emailPassword
        case google
        case guest
        case resendVerification
        case googleLegalAcceptance

        var loadingTitle: String {
            switch self {
            case .emailPassword: "Signing in..."
            case .google: "Signing in with Google..."
            case .guest: "Starting guest session..."
            case .resendVerification: "Sending verification email..."
            case .googleLegalAcceptance: "Saving acceptance..."
            }
        }
    }

    // MARK: - Form state
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI state
    @Published var isAuthenticating = false
    @Published private(set) var appError: AuthAppError?
    @Published var hasTriedSubmit = false
    @Published private(set) var activeAction: Action?
    @Published var isGoogleLegalAcceptanceRequired = false
    @Published var acceptedGoogleTerms = false
    @Published var acceptedGooglePrivacyPolicy = false
    @Published var hasTriedGoogleLegalSubmit = false

    // MARK: - Dependencies
    private let service: FirebaseAuthService?
    private let googleClient: GoogleAuthClient
    private let onSuccess: (String) -> Void
    private var pendingGoogleUID: String?

    // MARK: - Derived state
    var errorMessage: String? { appError?.errorDescription }
    var isEmailValid: Bool { AuthValidator.isValidEmail(email) }
    var isPasswordValid: Bool { AuthValidator.isValidLoginPassword(password) }
    var canSubmit: Bool { isEmailValid && isPasswordValid && !isAuthenticating }
    var emailHelperText: String? { AuthValidator.emailHelperText(email: email, hasTriedSubmit: hasTriedSubmit) }
    var passwordHelperText: String? { AuthValidator.loginPasswordHelperText(password: password, hasTriedSubmit: hasTriedSubmit) }
    var shouldOfferResendVerification: Bool { appError == .emailNotVerified }
    var loadingTitle: String { activeAction?.loadingTitle ?? "Authenticating..." }
    var canSubmitGoogleLegalAcceptance: Bool {
        acceptedGoogleTerms && acceptedGooglePrivacyPolicy && !isAuthenticating
    }
    var googleTermsHelperText: String? {
        AuthValidator.termsHelperText(
            acceptedTerms: acceptedGoogleTerms,
            hasTriedSubmit: hasTriedGoogleLegalSubmit
        )
    }
    var googlePrivacyPolicyHelperText: String? {
        AuthValidator.privacyPolicyHelperText(
            acceptedPrivacyPolicy: acceptedGooglePrivacyPolicy,
            hasTriedSubmit: hasTriedGoogleLegalSubmit
        )
    }

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

    /// Preview initializer.
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
        password = AuthValidator.sanitizedPassword(from: password)
        guard canSubmit, let service else { return }
        logAuth("login start email=\(maskedEmail(email))")

        startAction(.emailPassword)
        defer { finishAction() }
        do {
            let uid = try await service.signIn(email: email, password: password)
            appError = nil
            logAuth("login success uid=\(uid.prefix(8)) email=\(maskedEmail(email))")
            onSuccess(uid)
        } catch {
            let mapped = AuthAppError.mapToAppError(error)
            appError = mapped
            logAuth(
                "login failed email=\(maskedEmail(email)) mapped=\(mapped.errorDescription ?? "unknown") \(describe(error: error))"
            )
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

    private func describe(error: Error) -> String {
        let nsError = error as NSError
        return "domain=\(nsError.domain) code=\(nsError.code) message=\(nsError.localizedDescription)"
    }

    private func maskedEmail(_ email: String) -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atIndex = trimmed.firstIndex(of: "@") else { return "***" }
        let name = String(trimmed[..<atIndex])
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        let first = name.first.map(String.init) ?? ""
        return "\(first)***@\(domain)"
    }

    private func logAuth(_ message: String) {
#if DEBUG
        print("[App][Auth][LoginVM] \(message)")
#endif
    }
}

// MARK: - Google login

extension LoginViewModel {

    /// Starts Google sign in.
    /// User cancel keeps the screen silent.
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
            if try await requiresLegalAcceptanceAfterGoogleSignIn(service: service) {
                prepareGoogleLegalAcceptance(for: uid)
                appError = nil
                return
            }
            appError = nil
            onSuccess(uid)
        } catch {
            let mapped = AuthAppError.mapToAppError(error)
            if !mapped.isUserCancellation { appError = mapped }
        }
    }

    /// Stores required legal acceptance after Google sign-in, then completes app sign-in.
    func acceptGoogleLegalTerms() async {
        hasTriedGoogleLegalSubmit = true
        guard canSubmitGoogleLegalAcceptance else { return }
        guard let service, let pendingGoogleUID else {
            appError = .unknown("Unable to complete Google sign-in.")
            return
        }

        startAction(.googleLegalAcceptance)
        defer { finishAction() }

        do {
            try await service.storeTermsAcceptanceForCurrentUser(
                termsVersion: TermsContent.currentVersion,
                privacyVersion: TermsContent.privacyPolicyVersion,
                appVersion: appVersionForLegalAudit
            )
            _ = try await service.loadTermsAcceptanceForCurrentUser()
            let uid = pendingGoogleUID
            finishGoogleLegalAcceptance()
            appError = nil
            onSuccess(uid)
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    func clearGoogleLegalError() {
        appError = nil
    }

    func cancelGoogleLegalAcceptance() {
        do {
            try service?.signOut()
            finishGoogleLegalAcceptance()
            appError = nil
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }

    private func prepareGoogleLegalAcceptance(for uid: String) {
        pendingGoogleUID = uid
        acceptedGoogleTerms = false
        acceptedGooglePrivacyPolicy = false
        hasTriedGoogleLegalSubmit = false
        isGoogleLegalAcceptanceRequired = true
    }

    private func finishGoogleLegalAcceptance() {
        pendingGoogleUID = nil
        acceptedGoogleTerms = false
        acceptedGooglePrivacyPolicy = false
        hasTriedGoogleLegalSubmit = false
        isGoogleLegalAcceptanceRequired = false
    }

    private func requiresLegalAcceptanceAfterGoogleSignIn(service: FirebaseAuthService) async throws -> Bool {
        guard let acceptance = try await service.loadTermsAcceptanceForCurrentUser() else {
            return true
        }
        return acceptance.termsVersion != TermsContent.currentVersion
        || acceptance.privacyVersion != TermsContent.privacyPolicyVersion
        || acceptance.acceptedAt == nil
    }

    private var appVersionForLegalAudit: String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty == false) ? trimmed : nil
    }
}
