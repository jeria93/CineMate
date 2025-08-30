//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth
import UIKit

/// A tiny, preview-safe wrapper around Firebase Auth used by view models.
///
/// - In production: calls `Auth.auth()` for UID, sign-in, sign-out, etc.
/// - In Xcode Previews: never touches the SDK (guarded by `ProcessInfo.processInfo.isPreview`);
///   returns `nil`, no-ops, or throws `PreviewAuthError`.
/// - Keeps the API small and predictable for simple DI without protocols/factories.
final class FirebaseAuthService {

    /// The current user's UID if already signed in; otherwise `nil`.
    ///
    /// - Preview: Always returns `nil` to avoid booting Firebase in canvas.
    var currentUserID: String? {
        guard !ProcessInfo.processInfo.isPreview else { return nil }
        return Auth.auth().currentUser?.uid
    }

    /// Ensures there is a signed-in user and returns its UID.
    ///
    /// If a user is already signed in, returns that UID.
    /// Otherwise signs in anonymously and returns the new UID.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
    /// - Use this when you **need** a session (e.g. before starting a Firestore stream).
    func isLoggedIn() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Explicit anonymous sign-in. Returns the UID.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
    func signInAnonymously() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let res = try await Auth.auth().signInAnonymously()
        return res.user.uid
    }

    /// Signs out the current user.
    ///
    /// - Note: No-op in previews.
    /// - Throws: Firebase Auth errors in production if sign-out fails.
    func signOut() throws {
        guard !ProcessInfo.processInfo.isPreview else { return }
        try Auth.auth().signOut()
    }

    // MARK: - Email/Password

    /// Signs in with email and password. Returns the UID.
    ///
    /// Also enforces email verification:
    /// if the user is unverified, signs out and throws `EmailNotVerifiedError`.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
    func signIn(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let result = try await Auth.auth().signIn(withEmail: email, password: password)

        try await result.user.reload()
        if !result.user.isEmailVerified {
            try Auth.auth().signOut()
            throw EmailNotVerifiedError()
        }
        return result.user.uid
    }

    /// Creates an account, sends a verification email, then signs out.
    ///
    /// Use this when you require the user to verify before first sign-in.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
    func signUpRequiringEmailVerification(email: String, password: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            result.user.sendEmailVerification { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }

        try Auth.auth().signOut()
    }

    /// Creates a new account and signs the user in immediately. Returns the UID.
    ///
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors (e.g. email in use, weak password).
    func signUp(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    /// Re-sends a verification email to the currently signed-in user.
    ///
    /// - Throws: `PreviewAuthError` in previews,
    ///           `AuthServiceError.noCurrentUser` if nobody is signed in,
    ///           or Firebase Auth errors in production.
    func resendVerificationEmail() async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            user.sendEmailVerification { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }
    }

    /// Sends a password reset email.
    ///
    /// - Parameter email: Target account email.
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
    func sendPasswordReset(email: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    /// Links the current (typically anonymous) user to an email/password credential.
    ///
    /// If no user is signed in, creates a new email/password account instead.
    ///
    /// - Returns: The linked or newly created UID.
    /// - Throws: `PreviewAuthError` in previews, or Firebase Auth errors in production.
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

// MARK: - Google

extension FirebaseAuthService {

    /// Signs in with Google and returns the Firebase UID.
    ///
    /// - Parameters:
    ///   - viewController: A presenter used by Google to show its UI.
    ///   - client: A `GoogleAuthClient` that runs the Google sign-in flow.
    /// - Returns: The Firebase user UID on success.
    /// - Throws: `PreviewAuthError` in previews,
    ///           `UserCancelledSignInError` if the user cancels,
    ///           `GoogleSignInFailure` if tokens are missing,
    ///           or Firebase Auth errors in production.
    func signInWithGoogle(from viewController: UIViewController, using client: GoogleAuthClient) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        let tokens = try await client.signIn(from: viewController)
        let credential = GoogleAuthProvider.credential(
            withIDToken: tokens.idToken,
            accessToken: tokens.accessToken
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }
}
