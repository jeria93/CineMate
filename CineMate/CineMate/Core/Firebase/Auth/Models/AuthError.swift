//
//  AuthError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-22.
//

import Foundation
import FirebaseAuth

/// Auth errors used by the UI.
enum AuthAppError: LocalizedError, Equatable {

    case emailNotVerified
    case invalidEmail
    case invalidCredentials      // wrong password or user not found
    case emailInUse
    case weakPassword
    case network
    case accountDisabled
    case tooManyRequests
    case providerMismatch
    case reauthenticationRequired
    case providerUnavailable
    case googleSignInFailed
    case cancelled
    case preview
    case unknown(String)

    /// Short text for alerts and inline errors.
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
        case .reauthenticationRequired: "Please sign in again and try again"
        case .providerUnavailable: "This sign-in method is currently unavailable"
        case .googleSignInFailed: "Google sign-in failed. Please try again"
        case .cancelled: "Sign-in was cancelled"
        case .preview: "Auth is unavailable in Xcode Previews"
        case .unknown(let message): message
        }
    }

    /// True when the user canceled the flow.
    var isUserCancellation: Bool {
        if case .cancelled = self { return true } else { return false }
    }

    /// Maps any error into an `AuthAppError`.
    static func mapToAppError(_ error: Error) -> AuthAppError {
        if error is PreviewAuthError { return .preview }
        if error is EmailNotVerifiedError { return .emailNotVerified }
        if error is UserCancelledSignInError { return .cancelled }
        if error is GoogleSignInFailure { return .googleSignInFailed }
        if let serviceError = error as? AuthServiceError {
            return mapServiceError(serviceError)
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        if nsError.domain == "com.google.GIDSignIn" {
            return .googleSignInFailed
        }

        guard nsError.domain == AuthErrorDomain,
              let authErrorCode = AuthErrorCode(_bridgedNSError: nsError) else {
            return .unknown(nsError.localizedDescription)
        }
        return mapFirebaseAuthError(authErrorCode)
    }

    static func userMessage(for error: Error) -> String {
        mapToAppError(error).errorDescription ?? "Something went wrong"
    }

    private static func mapServiceError(_ error: AuthServiceError) -> AuthAppError {
        switch error {
        case .noCurrentUser:
            return .unknown("No signed-in account found")
        case .noCurrentUserEmail:
            return .unknown("No email address found for this account")
        case .passwordResetUnavailable:
            return .unknown("Password reset is only available for email accounts")
        case .unexpectedSignedInUser:
            return .unknown("Sign out and try again")
        }
    }

    private static let firebaseCodeMap: [Int: AuthAppError] = [
        AuthErrorCode.invalidEmail.rawValue: .invalidEmail,
        AuthErrorCode.wrongPassword.rawValue: .invalidCredentials,
        AuthErrorCode.userNotFound.rawValue: .invalidCredentials,
        AuthErrorCode.invalidCredential.rawValue: .invalidCredentials,
        AuthErrorCode.emailAlreadyInUse.rawValue: .emailInUse,
        AuthErrorCode.credentialAlreadyInUse.rawValue: .emailInUse,
        AuthErrorCode.weakPassword.rawValue: .weakPassword,
        AuthErrorCode.networkError.rawValue: .network,
        AuthErrorCode.userDisabled.rawValue: .accountDisabled,
        AuthErrorCode.tooManyRequests.rawValue: .tooManyRequests,
        AuthErrorCode.accountExistsWithDifferentCredential.rawValue: .providerMismatch,
        AuthErrorCode.requiresRecentLogin.rawValue: .reauthenticationRequired,
        AuthErrorCode.userTokenExpired.rawValue: .reauthenticationRequired,
        AuthErrorCode.operationNotAllowed.rawValue: .providerUnavailable
    ]

    private static func mapFirebaseAuthError(_ authErrorCode: AuthErrorCode) -> AuthAppError {
        firebaseCodeMap[authErrorCode.code.rawValue] ?? .unknown(authErrorCode.localizedDescription)
    }
}

/// Preview only error for blocked auth calls.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}

/// Error for unverified email sign in.
struct EmailNotVerifiedError: LocalizedError {
    var errorDescription: String? { "Please verify your email before signing in." }
}

/// Error for cancelled third party sign in.
struct UserCancelledSignInError: LocalizedError {
    var errorDescription: String? { "Sign-in was cancelled." }
}

/// Service level auth errors.
enum AuthServiceError: Error {
    /// No current user.
    case noCurrentUser
    /// Current user has no email in Firebase Auth.
    case noCurrentUserEmail
    /// Current provider does not support password reset.
    case passwordResetUnavailable
    /// Create account was called while a regular user is signed in.
    case unexpectedSignedInUser
}
