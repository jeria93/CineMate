//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth

/// # FirebaseAuthService
/// Lightweight, preview-safe wrapper around Firebase Auth used by view models.
/// - **Production:** Talks to `Auth.auth()` to read UID, anonymous sign-in, and sign-out.
/// - **Previews:** Never touches the SDK (guarded by `ProcessInfo.processInfo.isPreview`);
///   returns `nil`, no-ops, or throws `PreviewAuthError` to keep design-time fully offline.
/// - Keeps the surface minimal and deterministic for simple DI without protocols/factories.
final class FirebaseAuthService {

    /// Current user's UID if already signed in; `nil` otherwise.
    /// - **Previews:** Always `nil` (prevents accidental SDK bootstrap in canvas).
    var currentUserID: String? {
        guard !ProcessInfo.processInfo.isPreview else { return nil }
        return Auth.auth().currentUser?.uid
    }

    /// Ensures there is a signed-in user and returns its UID.
    /// - Returns: Existing UID or a newly created anonymous UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors in production.
    /// - **Note:** Use this when you *need* a session (e.g., before starting a Firestore stream).
    func isLoggedIn() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Explicit anonymous sign-in, returning the resulting UID.
    /// - Returns: Current or newly created anonymous UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors in production.
    /// - **Note:** Prefer `isLoggedIn()` if you simply need "some" user.
    func signInAnonymously() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let res = try await Auth.auth().signInAnonymously()
        return res.user.uid
    }

    /// Signs out the current user.
    /// - **Previews:** No-op.
    /// - Throws: Firebase Auth errors in production if sign-out fails.
    func signOut() throws {
        guard !ProcessInfo.processInfo.isPreview else { return }
        try Auth.auth().signOut()
    }
}

/// Error thrown in preview mode to indicate that Auth is intentionally unavailable.
/// Keeps Xcode Previews deterministic and avoids starting the Firebase SDK.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}
