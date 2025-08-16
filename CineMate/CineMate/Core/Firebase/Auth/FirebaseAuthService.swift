//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth

/// Thin wrapper around FirebaseAuth providing a simple identity surface:
/// read current user id, ensure a session (anonymous if needed), sign out.
final class FirebaseAuthService {

    /// Current user's UID if already signed in; `nil` otherwise.
    var currentUserID: String? { Auth.auth().currentUser?.uid }

    /// Ensures a signed-in user exists and returns its UID.
    /// - Returns: Existing or newly created anonymous UID.
    /// - Throws: FirebaseAuth errors when sign-in fails.
    func isLoggedIn() async throws -> String {
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Signs out and clears local auth state.
    /// - Throws: FirebaseAuth errors when sign-out fails.
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
