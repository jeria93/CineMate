//
//  GoogleAuthClient.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-29.
//

import UIKit
import GoogleSignIn

/// A small value type holding the tokens from Google Sign-In.
/// Use these to create a Firebase credential.
struct GoogleAuthTokens {
    /// The OpenID Connect ID token for the signed-in user.
    let idToken: String
    /// The short-lived access token from Google.
    let accessToken: String
}

@MainActor
/// A minimal client that starts Google Sign-In and returns tokens.
/// Conforms are Main Actor bound because sign-in presents UI.
protocol GoogleAuthClient {
    /// Starts Google Sign-In from a given view controller and returns tokens.
    ///
    /// - Parameter viewController: The view controller used to present Google's UI.
    /// - Returns: `GoogleAuthTokens` on success.
    /// - Throws:
    ///   - `PreviewAuthError` when running in Xcode Previews.
    ///   - `UserCancelledSignInError` if the user cancels the flow.
    ///   - `GoogleSignInFailure` if tokens are missing.
    ///   - Any underlying `NSError` from the Google SDK.
    func signIn(from viewController: UIViewController) async throws -> GoogleAuthTokens
}

/// Production implementation backed by the Google Sign-In SDK.
/// Reads the client ID from your app configuration (set up at launch).
struct LiveGoogleAuthClient: GoogleAuthClient {
    func signIn(from viewController: UIViewController) async throws -> GoogleAuthTokens {
        do {
            // Keep previews offline and deterministic.
            guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

            // Present Google's sign-in UI and await the result.
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

            // Extract required tokens.
            guard let id = result.user.idToken?.tokenString else {
                throw GoogleSignInFailure()
            }
            let access = result.user.accessToken.tokenString

            return GoogleAuthTokens(idToken: id, accessToken: access)

        } catch let ns as NSError {
            // Map Google's "canceled" into our neutral cancellation error.
            if ns.isGoogleSignInCanceled { throw UserCancelledSignInError() }
            throw ns
        }
    }
}

/// Error thrown when Google returns without usable tokens.
/// Shown as a friendly message to the user.
struct GoogleSignInFailure: LocalizedError {
    var errorDescription: String? { "Google sign-in failed. Please try again." }
}

// MARK: - Preview stub

/// Preview implementation used by Xcode Previews.
/// Always throws to avoid touching network or SDKs while designing UI.
struct PreviewGoogleAuthClient: GoogleAuthClient {
    func signIn(from viewController: UIViewController) async throws -> GoogleAuthTokens {
        throw PreviewAuthError()
    }
}

// MARK: - Helpers

private extension NSError {
    /// Returns `true` if the error means the user canceled Google Sign-In.
    /// Checks Google's domain and the `canceled` error code.
    var isGoogleSignInCanceled: Bool {
        domain == "com.google.GIDSignIn" && code == GIDSignInError.canceled.rawValue
    }
}
