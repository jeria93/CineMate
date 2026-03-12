//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth
import UIKit

/// Small auth service used by auth view models.
/// In previews it does not call Firebase.
final class FirebaseAuthService {

    // MARK: - State & Identity

    /// True when current user is anonymous.
    /// In previews this is always false.
    var isAnonymous: Bool {
        guard !ProcessInfo.processInfo.isPreview else { return false }
        return Auth.auth().currentUser?.isAnonymous == true
    }

    /// Current user uid if signed in.
    /// In previews this is always nil.
    var currentUserID: String? {
        guard !ProcessInfo.processInfo.isPreview else { return nil }
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Session

    /// Returns a signed in uid.
    /// If no user exists it signs in as anonymous.
    func isLoggedIn() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Starts an anonymous session and returns uid.
    /// If a normal user is active it signs out first.
    func signInAnonymously() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let auth = Auth.auth()

        if let currentUser = auth.currentUser {
            if currentUser.isAnonymous { return currentUser.uid }
            try auth.signOut()
        }

        let res = try await auth.signInAnonymously()
        return res.user.uid
    }

    /// Signs out current user.
    /// In previews this does nothing.
    func signOut() throws {
        guard !ProcessInfo.processInfo.isPreview else { return }
        try Auth.auth().signOut()
    }

    // MARK: - Email/Password

    /// Signs in with email and password.
    /// It also checks email verification.
    /// Unverified users are signed out and get EmailNotVerifiedError.
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

    /// Creates or upgrades to email account.
    /// It sends verification email and signs out.
    func createOrUpgradeEmailAccountRequiringVerification(email: String, password: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        let user = try await createOrUpgradeEmailAccount(email: email, password: password)
        do {
            try await sendVerificationEmail(to: user)
        } catch {
            try? Auth.auth().signOut()
            throw error
        }
        try Auth.auth().signOut()
    }

    /// Sends verification email to current user.
    /// Throws when no current user exists.
    func resendVerificationEmail() async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        try await sendVerificationEmail(to: user)
    }

    /// Sends password reset email.
    func sendPasswordReset(email: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Private

    private func createOrUpgradeEmailAccount(email: String, password: String) async throws -> User {
        let auth = Auth.auth()
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)

        if let currentUser = auth.currentUser {
            if currentUser.isAnonymous {
                let linkResult = try await currentUser.link(with: emailCredential)
                return linkResult.user
            }
            throw AuthServiceError.unexpectedSignedInUser
        }

        let signUpResult = try await auth.createUser(withEmail: email, password: password)
        return signUpResult.user
    }

    private func sendVerificationEmail(to user: User) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            user.sendEmailVerification { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }
    }
}

// MARK: - Google

extension FirebaseAuthService {

    /// Runs Google sign in and returns Firebase uid.
    /// The presenter is used by Google ui flow.
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
