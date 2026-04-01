//
//  AuthViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import Foundation
import SwiftUI

/// Main auth state view model.
/// Owns signed in state, loading state, and auth actions.
@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - UI State (observable & writable)

    /// Current user id.
    /// Nil means signed out.
    @Published var currentUID: String?

    /// True while an auth action runs.
    @Published var isAuthenticating = false

    /// Error text for UI.
    @Published var errorMessage: String?

    // MARK: - Dependencies (production only)

    /// Auth service.
    /// Nil only in preview init.
    private let service: FirebaseAuthService?

    // MARK: - Derived

    var isSignedIn: Bool { currentUID != nil }

    /// True when current user is guest.
    /// Always false in previews.
    var isGuest: Bool {
        if ProcessInfo.processInfo.isPreview { return false }
        return service?.isAnonymous ?? false
    }

    // MARK: - Init (Production)

    /// Production init.
    /// Reads current uid from the service.
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

    /// Starts guest sign in flow.
    func signInAsGuest() async {
        // Preview state only
        if ProcessInfo.processInfo.isPreview {
            guard errorMessage == nil else { return } // keep the “Error” preview intact
            currentUID = currentUID ?? AuthPreviewData.demoUID
            return
        }

        // Production call
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

    /// Signs out current user.
    func signOut() async {
        // Preview state only
        if ProcessInfo.processInfo.isPreview {
            currentUID = nil
            errorMessage = nil
            return
        }

        // Production call
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
    /// Provider label for account screen.
    var authProviderDescription: String {
        if ProcessInfo.processInfo.isPreview {
            return currentUID == nil ? "Signed out" : "Preview user"
        }
        return service?.authProviderDescription ?? "Signed out"
    }
}
