//
//  AuthError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-22.
//

import Foundation
import FirebaseAuth

/// **AuthAppError**
/// Small, UI-friendly error type for authentication flows.
/// Maps Firebase and custom errors to a compact set of app errors.
/// Keeps Firebase error codes hidden from the UI layer.
enum AuthAppError: LocalizedError, Equatable {

    // Core error cases we show in the UI
    case emailNotVerified
    case invalidEmail
    case invalidCredentials      // wrong password OR user not found
    case emailInUse
    case weakPassword
    case network
    case preview
    case unknown(String)

    /// Human-readable text for alerts/toasts.
    var errorDescription: String? {
        switch self {
        case .emailNotVerified: "Please verify your email before signing in"
        case .invalidEmail: "Enter a valid email address"
        case .invalidCredentials: "Wrong email or password"
        case .emailInUse: "Email is already in use"
        case .weakPassword: "Password is too weak"
        case .network: "Network error. Check your connection"
        case .preview: "Auth is unavailable in Xcode Previews"
        case .unknown(let message): message
        }
    }

    /// Maps any thrown `Error` (Firebase or custom) into `AuthAppError`.
    ///
    /// Steps:
    /// 1) Handle our own sentinel errors (`PreviewAuthError`, `EmailNotVerifiedError`).
    /// 2) Bridge to `NSError` to read `domain` and error code.
    /// 3) Ensure it is a Firebase Auth error (`AuthErrorDomain`).
    /// 4) Bridge to `AuthErrorCode` and switch on `.code`.
    /// 5) Return a compact, app-level case; fall back to `.unknown`.
    static func mapToAppError(_ error: Error) -> AuthAppError {
        // 1) Our own sentinel errors
        if error is PreviewAuthError { return .preview }
        if error is EmailNotVerifiedError { return .emailNotVerified }

        // 2) Bridge to NSError to inspect domain/message
        let nsError = error as NSError

        // 3) Only map Firebase Auth errors here
        guard nsError.domain == AuthErrorDomain,
              // 4) Version-safe bridge to AuthErrorCode (FirebaseAuth 12.x)
              let authErrorCode = AuthErrorCode(_bridgedNSError: nsError) else {
            return .unknown(nsError.localizedDescription)
        }

        // 5) Compact mapping to our app errors
        switch authErrorCode.code {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword, .userNotFound:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        default:
            return .unknown(authErrorCode.localizedDescription)
        }
    }
}

/// **PreviewAuthError**
/// Thrown in Xcode Previews to keep the Firebase SDK offline/dormant.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}

/// **EmailNotVerifiedError**
/// Thrown when sign-in is blocked until the user verifies their email.
struct EmailNotVerifiedError: LocalizedError {
    var errorDescription: String? { "Please verify your email before signing in." }
}

/// **AuthServiceError**
/// Internal service errors from `FirebaseAuthService`.
enum AuthServiceError: Error {
    /// No current user is available when one is required.
    case noCurrentUser
}
