//
//  AuthError.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-22.
//

import Foundation
import FirebaseAuth

/// App level auth errors for the UI.
/// This type maps Firebase and Google errors to short user messages.
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
    case reauthenticationRequired
    case providerUnavailable
    case googleSignInFailed
    case cancelled               // user cancelled a web/Google sign-in flow
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

    /// Maps any Error to an AuthAppError.
    /// App specific errors are checked first.
    /// Then network and Firebase errors are checked.
    /// Unknown errors fall back to unknown with the original message.
    static func mapToAppError(_ error: Error) -> AuthAppError {
        // 1) Our sentinels
        if error is PreviewAuthError { return .preview }
        if error is EmailNotVerifiedError { return .emailNotVerified }
        if error is UserCancelledSignInError { return .cancelled }
        if error is GoogleSignInFailure { return .googleSignInFailed }
        if let serviceError = error as? AuthServiceError {
            return mapServiceError(serviceError)
        }

        // 2) Generic network
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        if nsError.domain == "com.google.GIDSignIn" {
            return .googleSignInFailed
        }

        // 3) Firebase Auth mapping
        guard nsError.domain == AuthErrorDomain,
              let authErrorCode = AuthErrorCode(_bridgedNSError: nsError) else {
            // 4) Fallback
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

/// Used in previews to block real auth calls.
struct PreviewAuthError: LocalizedError {
    var errorDescription: String? { "Auth is unavailable in Xcode Previews." }
}

/// Used when the user must verify email before sign in.
struct EmailNotVerifiedError: LocalizedError {
    var errorDescription: String? { "Please verify your email before signing in." }
}

/// Used when the user cancels a third party sign in flow.
struct UserCancelledSignInError: LocalizedError {
    var errorDescription: String? { "Sign-in was cancelled." }
}

/// Service level auth errors.
enum AuthServiceError: Error {
    /// There is no current user.
    case noCurrentUser
    /// Create account was called while a non guest user is already signed in.
    case unexpectedSignedInUser
}
