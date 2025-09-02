//
//  AuthViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import Foundation

/// # AuthViewModel
/// Minimal auth view-model aligned with **Simple DI**.
/// - **Production:** Inject a `FirebaseAuthService` to read UID, sign in anonymously, and sign out.
/// - **Previews:** Static, deterministic state — no SDK calls or delays.
/// Keeps the surface tiny and testable (no `@EnvironmentObject` required).
@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - UI State (observable & writable)
    /// Currently signed-in user id (or `nil` when signed out / preview).
    @Published var currentUID: String?
    /// `true` while an auth action runs (drives spinners / disables inputs).
    @Published var isAuthenticating = false
    /// User-facing error text shown by the UI.
    @Published var errorMessage: String?

    // MARK: - Dependencies (prod only)
    /// Real Firebase wrapper in production; `nil` in previews.
    private let service: FirebaseAuthService?

    // MARK: - Derived
    /// `true` if the current Firebase user is anonymous.
    /// Always `false` in previews (we never boot the SDK there).
    var isGuest: Bool {
        if ProcessInfo.processInfo.isPreview { return false }
        return service?.isAnonymous ?? false
    }

    // MARK: - Init (production)
    /// Inject a real `FirebaseAuthService`. Seeds `currentUID` if not in previews.
    init(service: FirebaseAuthService) {
        self.service = service
        if !ProcessInfo.processInfo.isPreview {
            currentUID = service.currentUserID
        }
    }

    // MARK: - Init (preview)
    /// Preview-only initializer (no SDK, no async, no delays).
    /// - Parameters:
    ///   - simulatedUID: Pre-seeded UID (`nil` means “signed out”).
    ///   - previewError: Optional error banner to show immediately.
    ///   - previewIsAuthenticating: Start in loading state if `true`.
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

    /// Ensure a signed-in user exists (anonymous if needed).
    /// - **Preview:** Sets a static UID (unless an error is already shown).
    /// - **Production:** Calls `service.isLoggedIn()`, with loading + error mapping.
    func signInAsGuest() async {
        // Preview: static, deterministic behavior
        if ProcessInfo.processInfo.isPreview {
            guard errorMessage == nil else { return } // keep the “Error” preview intact
            currentUID = currentUID ?? AuthPreviewData.demoUID
            return
        }

        // Production: real SDK call wrapped with UI state
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.isLoggedIn()
            currentUID = uid
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Sign out the current user.
    /// - **Preview:** Resets local state only.
    /// - **Production:** Delegates to `service.signOut()` and clears local state.
    func signOut() {
        // Preview: local reset
        if ProcessInfo.processInfo.isPreview {
            currentUID = nil
            errorMessage = nil
            return
        }

        // Production: real sign-out
        do {
            try service?.signOut()
            currentUID = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
