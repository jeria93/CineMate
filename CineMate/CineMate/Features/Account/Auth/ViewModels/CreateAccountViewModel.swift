//
//  CreateAccountViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import Foundation

/// View model for CreateAccountView.
/// Uses one policy for new account and guest upgrade.
/// It sends verification email and signs out.
@MainActor
final class CreateAccountViewModel: ObservableObject {
    // MARK: - Form state
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var acceptedTerms: Bool = false
    @Published var acceptedPrivacyPolicy: Bool = false
    
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
    var isPasswordMatch: Bool {
        let sanitized = AuthValidator.sanitizedPasswordPair(password: password, confirmPassword: confirmPassword)
        return !sanitized.password.isEmpty && sanitized.password == sanitized.confirmPassword
    }
    var canSubmit: Bool { !isAuthenticating }
    private var isFormValid: Bool {
        isEmailValid
        && isPasswordValid
        && isPasswordMatch
        && acceptedTerms
        && acceptedPrivacyPolicy
    }
    
    // MARK: - Helper texts
    var emailHelperText: String? { AuthValidator.emailHelperText(email: email, hasTriedSubmit: hasTriedSubmit) }
    var passwordHelperText: String? { AuthValidator.passwordHelperText(password: password, hasTriedSubmit: hasTriedSubmit) }
    var confirmHelperText: String? {
        AuthValidator.confirmPasswordHelperText(
            password: password,
            confirmPassword: confirmPassword,
            hasTriedSubmit: hasTriedSubmit
        )
    }
    var termsHelperText: String? { AuthValidator.termsHelperText(acceptedTerms: acceptedTerms, hasTriedSubmit: hasTriedSubmit) }
    var privacyPolicyHelperText: String? {
        AuthValidator.privacyPolicyHelperText(
            acceptedPrivacyPolicy: acceptedPrivacyPolicy,
            hasTriedSubmit: hasTriedSubmit
        )
    }
    
    // MARK: - Init
    init(
        service: FirebaseAuthService,
        onVerificationEmailSent: @escaping () -> Void
    ) {
        self.service = service
        self.onVerificationEmailSent = onVerificationEmailSent
    }
    
    /// Preview init with static values.
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
    
    /// Validates and submits the form.
    func submit() async {
        hasTriedSubmit = true
        email = AuthValidator.sanitizedEmail(from: email)
        let sanitized = AuthValidator.sanitizedPasswordPair(password: password, confirmPassword: confirmPassword)
        password = sanitized.password
        confirmPassword = sanitized.confirmPassword
        
        guard let service else { return }
        guard isFormValid else { return }
        
        isAuthenticating = true
        appError = nil
        defer { isAuthenticating = false }
        
        do {
            try await service.createOrUpgradeEmailAccountRequiringVerification(
                email: email,
                password: password,
                acceptedTermsVersion: TermsContent.currentVersion,
                appVersion: appVersionForLegalAudit
            )
            appError = nil
            onVerificationEmailSent()
        } catch {
            appError = AuthAppError.mapToAppError(error)
        }
    }
    
    func clearError() {
        appError = nil
    }
    
    private var appVersionForLegalAudit: String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty == false) ? trimmed : nil
    }
}
