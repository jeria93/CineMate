//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth

/// # FirebaseAuthService
/// A thin wrapper around **FirebaseAuth** that gives the app a simple,
/// testable surface for user identity:
/// - read current user id,
/// - ensure a user exists (anonymous if needed),
/// - sign out safely.
///
/// ## Responsibilities
/// - Expose the current Firebase user ID (if any).
/// - Ensure a user session exists (sign in anonymously when no user is present).
/// - Sign out the current user and clear local session state.
///
/// ## Usage
/// ```swift
/// let auth = FirebaseAuthService()
///
/// // Get or create a user (anonymous if needed)
/// let uid = try await auth.isLoggedIn()
///
/// // Later, sign out
/// try auth.signOut()
/// ```
final class FirebaseAuthService {

    /// Returns the current Firebase user's UID if a session is already present,
    /// otherwise `nil`. This does **not** trigger any network calls.
    ///
    /// Common `nil` cases:
    /// - first app launch (no user yet),
    /// - after a successful `signOut()`,
    /// - app data cleared / reinstalled.
    var currentUserID: String? { Auth.auth().currentUser?.uid }

    /// Ensures there is a logged-in user and returns its UID.
    /// - If a user is already logged in, returns that user's UID immediately.
    /// - If no user exists, signs in **anonymously** and returns the new UID.
    ///
    /// - Returns: The UID of the current (or newly created anonymous) user.
    /// - Throws: An error from FirebaseAuth if anonymous sign-in fails.
    func isLoggedIn() async throws -> String {
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Signs out the current user and clears the local auth state.
    /// - Throws: An error from FirebaseAuth if sign-out fails.
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
