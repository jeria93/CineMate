//
//  GoogleSignInBootstrap.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-29.
//

import Foundation
import FirebaseCore
import GoogleSignIn

/// Configures Google Sign-In once for the whole app.
/// - Skips Xcode Previews.
/// - Reads the `clientID` from Firebase (`GoogleService-Info.plist`).
/// - Sets `GIDSignIn.sharedInstance.configuration`.
/// Call this early (e.g., in `CineMate.init()`), before you start a sign-in flow.
enum GoogleSignInBootstrap {
    private static var isConfigured = false

    /// Idempotent setup for Google Sign-In.
    ///
    /// Safe to call multiple times: it will only run once per launch.
    /// If the Firebase `clientID` is missing, an assertion will fire in Debug
    /// (which usually means the real `GoogleService-Info.plist` is not in the target).
    static func ensureConfigured() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard !isConfigured else { return }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            assertionFailure("Missing Firebase clientID. Add GoogleService-Info.plist to target.")
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        isConfigured = true
    }
}
