//
//  AuthViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-17.
//

import Foundation

/// **AuthViewModel**
/// Minimal auth view-model aligned with “Simple DI”.
/// - **Production:** Inject a `FirebaseAuthService` to read UID, anonymous sign-in, and sign-out.
/// - **Previews:** Use the static init to set deterministic state (no SDK calls, no delays).
/// Keeps the surface tiny, avoids `@EnvironmentObject`, and makes previews trivial.
@MainActor
final class AuthViewModel: ObservableObject {

    /// Currently signed-in user id (or `nil` when signed out / preview state).
    @Published var currentUID: String?

    /// `true` while an auth action is in flight (drives spinners / disabled buttons).
    @Published var isAuthenticating = false

    /// User-facing error text (shown in UI when an operation fails).
    @Published var errorMessage: String?

    /// Injected production service. `nil` in previews (so we never touch the SDK there).
    private let service: FirebaseAuthService?

    // MARK: - Init (production)

    /// Production initializer.
    /// Inject a real `FirebaseAuthService`. Seeds `currentUID` if not running in previews.
    init(service: FirebaseAuthService) {
        self.service = service
        if !ProcessInfo.processInfo.isPreview {
            currentUID = service.currentUserID
        }
    }

    // MARK: - Init (preview)

    /// Preview initializer.
    /// Pure static state: no SDK, no async, no delays.
    /// - Parameters:
    ///   - previewUID: Pre-seeded UID (nil means “signed out”).
    ///   - previewError: Optional error banner to show immediately.
    ///   - previewBusy: If `true`, the UI starts in a loading state.
    init(previewUID: String? = nil,
         previewError: String? = nil,
         previewBusy: Bool = false)
    {
        self.service = nil
        self.currentUID = previewUID
        self.errorMessage = previewError
        self.isAuthenticating = previewBusy
    }

    // MARK: - Actions

    /// Ensure a signed-in user exists (anonymous if needed).
    /// - **Preview:** Just sets a static UID (unless an error is already shown).
    /// - **Production:** Calls `service.isLoggedIn()`, shows spinner and errors as needed.
    func signInAsGuest() async {
        // Preview-path: static, deterministic behavior
        if ProcessInfo.processInfo.isPreview {
            guard errorMessage == nil else { return } // keep the “Error” preview intact
            currentUID = currentUID ?? AuthPreviewData.demoUID
            return
        }

        // Production-path: real SDK call wrapped with UI state
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
    /// - **Preview:** Resets static state only.
    /// - **Production:** Delegates to `service.signOut()` and clears local state.
    func signOut() {
        // Preview-path: local reset
        if ProcessInfo.processInfo.isPreview {
            currentUID = nil
            errorMessage = nil
            return
        }

        // Production-path: real sign-out
        do {
            try service?.signOut()
            currentUID = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
