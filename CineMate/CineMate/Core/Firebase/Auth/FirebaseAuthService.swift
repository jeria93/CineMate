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
    /// - Note: Use this when you *need* a session (e.g., before starting a Firestore stream).
    func isLoggedIn() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Explicit anonymous sign-in.
    /// - Returns: Current UID if already signed in, otherwise a newly created anonymous UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors in production.
    func signInAnonymously() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let res = try await Auth.auth().signInAnonymously()
        return res.user.uid
    }

    /// Signs out the current user.
    /// - Throws: Firebase Auth errors in production if sign-out fails.
    /// - Note: No-op in previews.
    func signOut() throws {
        guard !ProcessInfo.processInfo.isPreview else { return }
        try Auth.auth().signOut()
    }

    /// Email/password sign-in.
    /// - Parameters:
    ///   - email: Account email.
    ///   - password: Account password.
    /// - Returns: The signed-in user's UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors (e.g. wrong password, user not found) in production.
    func signIn(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    /// Creates a new account with email/password and signs the user in.
    /// - Parameters:
    ///   - email: New account email.
    ///   - password: New account password.
    /// - Returns: The newly created user's UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors (e.g. email already in use, weak password) in production.
    func signUp(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    /// Sends a password reset email.
    /// - Parameter email: Target account email.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors (e.g. invalid email) in production.
    /// - Note: Requires the Email/Password provider to be enabled in Firebase Console.
    func sendPasswordReset(email: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    /// Links the current (typically anonymous) user to an email/password credential.
    /// - If no user is signed in, this creates a new email/password account instead.
    /// - Parameters:
    ///   - email: Email to link or create.
    ///   - password: Password to link or create.
    /// - Returns: The linked/created user's UID.
    /// - Throws: `PreviewAuthError` in previews; Firebase Auth errors in production (e.g. credential already in use).
    /// - Note: Enable both **Anonymous** and **Email/Password** providers in Firebase Console.
    func linkAnonymousAccount(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        guard let currentUser = Auth.auth().currentUser else {
            let signUpResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return signUpResult.user.uid
        }

        let linkResult = try await currentUser.link(with: emailCredential)
        return linkResult.user.uid
    }

}

/// Error thrown in preview mode to indicate that Auth is intentionally unavailable.
/// Keeps Xcode Previews deterministic and avoids starting the Firebase SDK.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}
