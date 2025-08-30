//
//  AuthError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-22.
//

import Foundation
import FirebaseAuth

/// A small, UI-friendly error type for the app’s auth flows.
/// Converts Firebase/Google errors into simple cases the UI can show.
/// Keeps SDK-specific error codes out of the view layer.
enum AuthAppError: LocalizedError, Equatable {

    // Core error cases we present in the UI
    case emailNotVerified
    case invalidEmail
    case invalidCredentials      // wrong password OR user not found
    case emailInUse
    case weakPassword
    case network
    case accountDisabled         // disabled in backend
    case tooManyRequests         // throttled/abuse protection
    case providerMismatch        // account exists with a different sign-in method
    case cancelled               // user cancelled a web/Google sign-in flow
    case preview
    case unknown(String)

    /// Short, user-facing text for alerts/toasts.
    var errorDescription: String? {
        switch self {
        case .emailNotVerified: "Please verify your email before signing in"
        case .invalidEmail: "Enter a valid email address"
        case .invalidCredentials: "Wrong email or password"
        case .emailInUse: "Email is already in use"
        case .weakPassword: "Password is too weak"
        case .network: "Network error. Check your connection"
        case .accountDisabled: "This account has been disabled"
        case .tooManyRequests: "Too many attempts. Try again later"
        case .providerMismatch: "Account exists with a different sign-in method"
        case .cancelled: "Sign-in was cancelled"
        case .preview: "Auth is unavailable in Xcode Previews"
        case .unknown(let message): message
        }
    }

    /// Returns true for benign, user-initiated cancellation (usually no toast).
    var isUserCancellation: Bool {
        if case .cancelled = self { return true } else { return false }
    }

    /// Maps any thrown `Error` into an `AuthAppError`.
    ///
    /// Mapping order:
    /// 1) App sentinel errors (preview, email not verified, user cancelled, Google tokens missing)
    /// 2) Generic network errors
    /// 3) Firebase Auth errors by `AuthErrorCode`
    /// 4) Fallback to `.unknown` with the original message
    static func mapToAppError(_ error: Error) -> AuthAppError {
        // 1) Our sentinels
        if error is PreviewAuthError { return .preview }
        if error is EmailNotVerifiedError { return .emailNotVerified }
        if error is UserCancelledSignInError { return .cancelled }
        if error is GoogleSignInFailure { return .unknown("Google sign-in failed. Please try again.") }

        // 2) Generic network
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }

        // 3) Firebase Auth mapping
        guard nsError.domain == AuthErrorDomain,
              let authErrorCode = AuthErrorCode(_bridgedNSError: nsError) else {
            // 4) Fallback
            return .unknown(nsError.localizedDescription)
        }

        switch authErrorCode.code {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword, .userNotFound:
            return .invalidCredentials
        case .emailAlreadyInUse, .credentialAlreadyInUse:
            return .emailInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        case .userDisabled:
            return .accountDisabled
        case .tooManyRequests:
            return .tooManyRequests
        case .accountExistsWithDifferentCredential:
            return .providerMismatch
        default:
            return .unknown(authErrorCode.localizedDescription)
        }
    }
}

/// Thrown in Xcode Previews to keep the Firebase SDK offline/dormant.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}

/// Thrown when sign-in is blocked until the user verifies their email.
struct EmailNotVerifiedError: LocalizedError {
    var errorDescription: String? { "Please verify your email before signing in." }
}

/// Thrown when the user cancels a third-party flow (e.g., Google web/SFAuth flow).
struct UserCancelledSignInError: LocalizedError {
    var errorDescription: String? { "Sign-in was cancelled." }
}

/// Internal service errors used by `FirebaseAuthService`.
enum AuthServiceError: Error {
    /// No current user exists when one is required.
    case noCurrentUser
}
