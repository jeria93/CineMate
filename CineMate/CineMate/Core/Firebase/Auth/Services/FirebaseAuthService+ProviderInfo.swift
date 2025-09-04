//
//  FirebaseAuthService+ProviderInfo.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-04.
//

import Foundation
import FirebaseAuth

/// FirebaseAuthService+ProviderInfo
/// --------------------------------
/// Adds a small helper to describe **how** the current user is signed in.
/// Returns short, user-friendly labels like:
/// - "Guest"
/// - "Email (a@b.com)"
/// - "Google (a@b.com)"
/// - "Apple (a@b.com)"
/// - "Other (a@b.com)"
extension FirebaseAuthService {

    /// Human-readable description of the current auth provider.
    ///
    /// Behavior:
    /// - **Previews:** never touches Firebase --> returns "Preview user".
    /// - **Signed out:** returns "Signed out".
    /// - **Anonymous:** returns "Guest".
    /// - **Provider-backed:** maps `providerID` to a label (google.com --> "Google",
    ///   apple.com --> "Apple", password --> "Email"); falls back to "Other".
    /// - If an email exists, it is appended as `" (email)"`.
    var authProviderDescription: String {
        // Skip SDK in previews
        guard !ProcessInfo.processInfo.isPreview else {
            return "Preview user"
        }
        guard let user = Auth.auth().currentUser else {
            return "Signed out"
        }
        if user.isAnonymous { return "Guest" }

        // Prefer explicit providers
        let providers = user.providerData.map(\.providerID) // e.g. "google.com", "apple.com", "password"
        let email = (user.email ?? "").trimmingCharacters(in: .whitespaces)

        func label(_ name: String) -> String {
            email.isEmpty ? name : "\(name) (\(email))"
        }

        if providers.contains("google.com") { return label("Google") }
        if providers.contains("apple.com")  { return label("Apple") }
        if providers.contains("password")   { return label("Email") }

        // Fallback for any other provider
        return label("Other")
    }
}
