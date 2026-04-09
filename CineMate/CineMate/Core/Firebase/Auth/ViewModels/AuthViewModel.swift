//
//  AuthViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import Foundation
import SwiftUI
import FirebaseAuth

/// Auth state for account and sign in screens.
@MainActor
final class AuthViewModel: ObservableObject {
    private static let changeEmailCooldownSeconds = 30.0
    
    // MARK: - UI State
    
    /// Current user ID. Nil means signed out.
    @Published var currentUID: String?
    
    /// True while an auth task is running.
    @Published var isAuthenticating = false
    
    /// Error text shown by the UI.
    @Published var errorMessage: String?
    
    /// End time for change email cooldown.
    private var changeEmailCooldownUntil: Date?
    
    // MARK: - Dependencies
    
    /// Auth service. Nil only in preview init.
    private let service: FirebaseAuthService?
    
    // MARK: - Derived
    
    var isSignedIn: Bool { currentUID != nil }
    
    /// True when the current user is a guest account.
    var isGuest: Bool {
        if ProcessInfo.processInfo.isPreview { return false }
        return service?.isAnonymous ?? false
    }
    
    // MARK: - Init (Production)
    
    init(service: FirebaseAuthService) {
        self.service = service
        if !ProcessInfo.processInfo.isPreview {
            currentUID = service.currentUserID
        }
    }
    
    // MARK: - Init (Preview)
    
    init(
        simulatedUID: String? = nil,
        previewError: String? = nil,
        previewIsAuthenticating: Bool = false
    ) {
        self.service = nil
        self.currentUID = simulatedUID
        self.errorMessage = previewError
        self.isAuthenticating = previewIsAuthenticating
    }
    
    // MARK: - Actions
    
    /// Starts guest sign in.
    func signInAsGuest() async {
        if ProcessInfo.processInfo.isPreview {
            guard errorMessage == nil else { return }
            currentUID = currentUID ?? AuthPreviewData.demoUID
            return
        }
        
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signInAnonymously()
            currentUID = uid
            errorMessage = nil
        } catch {
            errorMessage = AuthAppError.userMessage(for: error)
        }
    }
    
    /// Signs out the current user.
    func signOut() async {
        if ProcessInfo.processInfo.isPreview {
            currentUID = nil
            errorMessage = nil
            changeEmailCooldownUntil = nil
            return
        }
        
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            if service.isAnonymous {
                _ = try await service.deleteCurrentAccountWithDataCleanup()
            } else {
                try service.signOut()
            }
            currentUID = nil
            errorMessage = nil
            changeEmailCooldownUntil = nil
        } catch {
            errorMessage = AuthAppError.userMessage(for: error)
        }
    }
    
    /// Reloads auth user data from server and refreshes local account info.
    func refreshCurrentUserFromServer() async {
        if ProcessInfo.processInfo.isPreview { return }
        guard let service, currentUID != nil else { return }
        
        do {
            try await service.reloadCurrentUser()
            currentUID = service.currentUserID
            logAuth("refreshCurrentUser success uid=\(currentUID?.prefix(8) ?? "none")")
        } catch {
            currentUID = service.currentUserID
            logAuth("refreshCurrentUser failed \(describe(error: error))")
        }
    }
}

// MARK: - Email change API

extension AuthViewModel {
    
    /// Result for email change action.
    enum ChangeEmailResult {
        case verificationSent(email: String)
        case unavailable
        case cooldown(seconds: Int)
        case needsRecentLogin
        case failure(String)
    }
    
    /// Sends an email change verification link to the new address.
    func sendChangeEmailVerification(to newEmail: String) async -> ChangeEmailResult {
        if ProcessInfo.processInfo.isPreview { return .failure("Unavailable in previews") }
        guard let service, currentUID != nil else { return .failure("No current user") }
        guard service.canChangeEmail else { return .unavailable }
        let cooldownSeconds = changeEmailCooldownRemainingSeconds()
        guard cooldownSeconds == 0 else {
            logAuth("changeEmail cooldown remaining=\(cooldownSeconds)s")
            return .cooldown(seconds: cooldownSeconds)
        }
        
        let normalizedNewEmail = AuthValidator.sanitizedEmail(from: newEmail)
        guard AuthValidator.isValidEmail(normalizedNewEmail) else {
            return .failure(AuthValidator.Message.invalidEmail)
        }
        
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            try await service.sendChangeEmailVerification(to: normalizedNewEmail)
            errorMessage = nil
            changeEmailCooldownUntil = Date().addingTimeInterval(Self.changeEmailCooldownSeconds)
            logAuth("changeEmail verificationSent email=\(maskedEmail(normalizedNewEmail))")
            return .verificationSent(email: normalizedNewEmail)
        } catch {
            if service.isRecentLoginRequired(error) {
                errorMessage = nil
                logAuth("changeEmail needsRecentLogin")
                return .needsRecentLogin
            }
            let message = mapChangeEmailErrorMessage(for: error)
            errorMessage = message
            logAuth("changeEmail failed message=\(message) \(describe(error: error))")
            return .failure(message)
        }
    }
    
    private func changeEmailCooldownRemainingSeconds(at date: Date = Date()) -> Int {
        guard let changeEmailCooldownUntil else { return 0 }
        return max(Int(ceil(changeEmailCooldownUntil.timeIntervalSince(date))), 0)
    }
}

// MARK: - Password reset API

extension AuthViewModel {
    
    /// Result for password reset action.
    enum PasswordResetResult {
        case sent(email: String)
        case unavailable
        case failure(String)
    }
    
    /// Sends a password reset email for the signed in account.
    func sendPasswordResetForCurrentUser() async -> PasswordResetResult {
        if ProcessInfo.processInfo.isPreview { return .failure("Unavailable in previews") }
        guard let service, currentUID != nil else { return .failure("No current user") }
        guard service.canSendPasswordReset else { return .unavailable }
        
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            let email = try await service.sendPasswordResetToCurrentUserEmail()
            errorMessage = nil
            logAuth("passwordReset sent email=\(maskedEmail(email))")
            return .sent(email: email)
        } catch {
            let message = AuthAppError.userMessage(for: error)
            errorMessage = message
            logAuth("passwordReset failed message=\(message)")
            return .failure(message)
        }
    }
}

// MARK: - Deletion API

extension AuthViewModel {
    
    /// Result for delete account action.
    enum DeleteAccountResult {
        case success
        case needsRecentLogin
        case failure(String)
    }
    
    func deleteCurrentAccount() async -> DeleteAccountResult {
        if ProcessInfo.processInfo.isPreview { return .failure("Unavailable in previews") }
        guard let service = self.service, currentUID != nil else {
            return .failure("No current user")
        }
        
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            let result = try await service.deleteCurrentAccountWithDataCleanup()
            switch result {
            case .success:
                self.currentUID = nil
                self.errorMessage = nil
                self.changeEmailCooldownUntil = nil
                return .success
            case .requiresRecentLogin:
                self.currentUID = nil
                self.errorMessage = nil
                self.changeEmailCooldownUntil = nil
                return .needsRecentLogin
            }
        } catch {
            let message = AuthAppError.userMessage(for: error)
            self.errorMessage = message
            return .failure(message)
        }
    }
}

// MARK: - Read-only auth info

extension AuthViewModel {
    /// Provider label for the account screen.
    var authProviderDescription: String {
        if ProcessInfo.processInfo.isPreview {
            return currentUID == nil ? "Signed out" : "Preview user"
        }
        return service?.authProviderDescription ?? "Signed out"
    }
    
    /// Email shown on the account screen.
    var currentUserEmail: String? {
        if ProcessInfo.processInfo.isPreview {
            return currentUID == nil ? nil : "preview@example.com"
        }
        return service?.currentUserEmail
    }
    
    /// True when this account supports password reset emails.
    var canSendPasswordReset: Bool {
        if ProcessInfo.processInfo.isPreview { return currentUID != nil }
        return service?.canSendPasswordReset ?? false
    }
    
    /// True when this account supports email change.
    var canChangeEmail: Bool {
        if ProcessInfo.processInfo.isPreview { return currentUID != nil }
        return service?.canChangeEmail ?? false
    }
}

// MARK: - Debug logging

private extension AuthViewModel {
    func mapChangeEmailErrorMessage(for error: Error) -> String {
        let nsError = error as NSError
        let normalizedDescription = nsError.localizedDescription.lowercased()
        if normalizedDescription.contains("supplied auth credential is malformed or has expired") {
            return "Please sign in again to change your email"
        }
        
        if nsError.domain == AuthErrorDomain,
           let authErrorCode = AuthErrorCode(_bridgedNSError: nsError) {
            switch authErrorCode {
            case .invalidCredential, .requiresRecentLogin, .userTokenExpired:
                return "Please sign in again to change your email"
            case .invalidEmail:
                return AuthValidator.Message.invalidEmail
            default:
                break
            }
        }
        
        return AuthAppError.userMessage(for: error)
    }
    
    func describe(error: Error) -> String {
        let nsError = error as NSError
        return "domain=\(nsError.domain) code=\(nsError.code) message=\(nsError.localizedDescription)"
    }
    
    func maskedEmail(_ email: String) -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atIndex = trimmed.firstIndex(of: "@") else { return "***" }
        let name = String(trimmed[..<atIndex])
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        let first = name.first.map(String.init) ?? ""
        return "\(first)***@\(domain)"
    }
    
    func logAuth(_ message: String) {
#if DEBUG
        print("[App][Auth][ViewModel] \(message)")
#endif
    }
}
