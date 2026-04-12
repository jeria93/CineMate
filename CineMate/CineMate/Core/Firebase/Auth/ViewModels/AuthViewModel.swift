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
    
    /// Saved terms acceptance metadata for this account.
    @Published private(set) var termsAcceptance: TermsAcceptanceSnapshot?
    
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
            termsAcceptance = nil
            return
        }
        
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signInAnonymously()
            currentUID = uid
            termsAcceptance = nil
            errorMessage = nil
        } catch {
            errorMessage = AuthAppError.userMessage(for: error)
        }
    }
    
    /// Signs out the current user.
    func signOut() async {
        if ProcessInfo.processInfo.isPreview {
            currentUID = nil
            termsAcceptance = nil
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
            termsAcceptance = nil
            errorMessage = nil
            changeEmailCooldownUntil = nil
        } catch {
            errorMessage = AuthAppError.userMessage(for: error)
        }
    }
    
    /// Reloads auth user data from server and refreshes local account info.
    func refreshCurrentUserFromServer() async {
        if ProcessInfo.processInfo.isPreview { return }
        guard let service else {
            termsAcceptance = nil
            return
        }
        guard currentUID != nil else {
            termsAcceptance = nil
            return
        }
        
        do {
            try await service.reloadCurrentUser()
            currentUID = service.currentUserID
            logAuth("refreshCurrentUser success uid=\(currentUID?.prefix(8) ?? "none")")
        } catch {
            currentUID = service.currentUserID
            logAuth("refreshCurrentUser failed \(describe(error: error))")
        }
        await refreshTermsAcceptance()
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
                self.termsAcceptance = nil
                self.errorMessage = nil
                self.changeEmailCooldownUntil = nil
                return .success
            case .requiresRecentLogin:
                self.currentUID = nil
                self.termsAcceptance = nil
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
    
    /// Accepted terms version shown on the account screen.
    var acceptedTermsVersionText: String? {
        termsAcceptance?.termsVersion
    }
    
    /// Accepted timestamp shown on the account screen.
    var acceptedTermsAtText: String? {
        guard let date = termsAcceptance?.acceptedAt else { return nil }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    
    /// App version used when the user accepted terms.
    var acceptedTermsAppVersionText: String? {
        termsAcceptance?.appVersion
    }
    
    /// One-line legal summary shown on the account screen.
    var acceptedTermsSummaryText: String? {
        guard let version = termsAcceptance?.termsVersion else { return nil }
        if let acceptedAt = termsAcceptance?.acceptedAt {
            return "You accepted version \(version) on \(formattedTermsDate(acceptedAt))."
        }
        return "You accepted version \(version)."
    }
    
    /// True when the saved terms version is older than the current app terms.
    var isAcceptedTermsOutdated: Bool {
        guard let acceptedVersion = termsAcceptance?.termsVersion else { return false }
        guard acceptedVersion != TermsContent.currentVersion else { return false }
        
        guard
            let acceptedDate = termsVersionDate(from: acceptedVersion),
            let currentDate = termsVersionDate(from: TermsContent.currentVersion)
        else {
            return true
        }
        return acceptedDate < currentDate
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
    
    var appVersionForLegalAudit: String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty == false) ? trimmed : nil
    }
    
    func termsVersionDate(from raw: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: raw.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func formattedTermsDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Legal metadata API

extension AuthViewModel {
    /// Result for accepting latest terms on the account screen.
    enum AcceptTermsResult {
        case saved
        case unavailable
        case failure(String)
    }
    
    /// Stores the current terms version for the signed in user.
    func acceptCurrentTermsVersion() async -> AcceptTermsResult {
        if ProcessInfo.processInfo.isPreview {
            termsAcceptance = TermsAcceptanceSnapshot(
                termsVersion: TermsContent.currentVersion,
                acceptedAt: Date(),
                appVersion: "Preview"
            )
            return .saved
        }
        
        guard let service, currentUID != nil, !service.isAnonymous else {
            return .unavailable
        }
        
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            try await service.storeTermsAcceptanceForCurrentUser(
                termsVersion: TermsContent.currentVersion,
                appVersion: appVersionForLegalAudit
            )
            termsAcceptance = try await service.loadTermsAcceptanceForCurrentUser()
            errorMessage = nil
            return .saved
        } catch {
            let message = AuthAppError.userMessage(for: error)
            errorMessage = message
            return .failure(message)
        }
    }
    
    /// Loads saved terms acceptance metadata for the current user.
    func refreshTermsAcceptance() async {
        if ProcessInfo.processInfo.isPreview {
            termsAcceptance = currentUID == nil
            ? nil
            : TermsAcceptanceSnapshot(
                termsVersion: TermsContent.currentVersion,
                acceptedAt: Date(),
                appVersion: "Preview"
            )
            return
        }
        
        guard let service, currentUID != nil, !service.isAnonymous else {
            termsAcceptance = nil
            return
        }
        
        do {
            termsAcceptance = try await service.loadTermsAcceptanceForCurrentUser()
        } catch {
            termsAcceptance = nil
            logAuth("refreshTermsAcceptance failed \(describe(error: error))")
        }
    }
}
