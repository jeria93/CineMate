//
//  AuthViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import Foundation
import SwiftUI

/// Auth state used by account and sign in screens.
@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - UI State
    
    /// Current user ID. Nil means signed out.
    @Published var currentUID: String?
    
    /// True while an auth task is running.
    @Published var isAuthenticating = false
    
    /// Error text shown by the UI.
    @Published var errorMessage: String?
    
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
    
    /// Production init.
    init(service: FirebaseAuthService) {
        self.service = service
        if !ProcessInfo.processInfo.isPreview {
            currentUID = service.currentUserID
        }
    }
    
    // MARK: - Init (Preview)
    
    /// Preview init with static values.
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
        } catch {
            errorMessage = AuthAppError.userMessage(for: error)
        }
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
            return .sent(email: email)
        } catch {
            let message = AuthAppError.userMessage(for: error)
            errorMessage = message
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
                return .success
            case .requiresRecentLogin:
                self.currentUID = nil
                self.errorMessage = nil
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
}
