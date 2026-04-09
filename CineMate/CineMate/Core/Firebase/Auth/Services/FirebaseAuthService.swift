//
//  FirebaseAuthService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-09.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import UIKit

/// Auth service for sign in and account actions.
/// In previews it throws preview errors instead of calling Firebase.
final class FirebaseAuthService {

    // MARK: - State & Identity

    /// True when the current user is a guest account.
    var isAnonymous: Bool {
        guard !ProcessInfo.processInfo.isPreview else { return false }
        return Auth.auth().currentUser?.isAnonymous == true
    }

    /// Current user ID when signed in.
    var currentUserID: String? {
        guard !ProcessInfo.processInfo.isPreview else { return nil }
        return Auth.auth().currentUser?.uid
    }

    /// Current user email when available.
    var currentUserEmail: String? {
        guard !ProcessInfo.processInfo.isPreview else { return nil }
        let email = Auth.auth().currentUser?.email?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let email, !email.isEmpty else { return nil }
        return email
    }

    /// True when the current account can receive a password reset email.
    /// Requires email and password sign in.
    var canSendPasswordReset: Bool {
        guard !ProcessInfo.processInfo.isPreview else { return false }
        guard let user = Auth.auth().currentUser, !user.isAnonymous else { return false }
        let providers = user.providerData.map(\.providerID)
        guard providers.contains("password") else { return false }
        return !(user.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// True when the current account can request an email change.
    var canChangeEmail: Bool {
        canSendPasswordReset
    }

    // MARK: - Session

    /// Returns the signed in user ID.
    /// If no user exists, it starts a guest session.
    func isLoggedIn() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        if let uid = currentUserID { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Starts a guest session and returns the user ID.
    /// If a regular user is active, it signs out first.
    func signInAnonymously() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let auth = Auth.auth()

        if let currentUser = auth.currentUser {
            if currentUser.isAnonymous { return currentUser.uid }
            try signOutCurrentUser(auth: auth)
        }

        let res = try await auth.signInAnonymously()
        return res.user.uid
    }

    /// Signs out the current user.
    func signOut() throws {
        guard !ProcessInfo.processInfo.isPreview else { return }
        try signOutCurrentUser(auth: Auth.auth())
    }

    // MARK: - Email/Password

    /// Signs in with email and password.
    /// Unverified users are signed out and return `EmailNotVerifiedError`.
    func signIn(email: String, password: String) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let sanitizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        logAuth("signIn start email=\(maskedEmail(sanitizedEmail))")

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            try await result.user.reload()
            if !result.user.isEmailVerified {
                logAuth("signIn blocked email=\(maskedEmail(sanitizedEmail)) reason=emailNotVerified")
                try signOut()
                throw EmailNotVerifiedError()
            }
            logAuth("signIn success uid=\(result.user.uid.prefix(8)) email=\(maskedEmail(sanitizedEmail))")
            return result.user.uid
        } catch {
            logAuth(
                "signIn failed email=\(maskedEmail(sanitizedEmail)) \(describe(error: error))"
            )
            throw error
        }
    }

    /// Creates an email account or upgrades a guest account.
    /// Sends a verification email and then signs out.
    func createOrUpgradeEmailAccountRequiringVerification(email: String, password: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        let user = try await createOrUpgradeEmailAccount(email: email, password: password)
        do {
            try await sendVerificationEmail(to: user)
        } catch {
            try? signOut()
            throw error
        }
        try signOut()
    }

    /// Sends a verification email to the current user.
    func resendVerificationEmail() async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }
        try await sendVerificationEmail(to: user)
    }

    /// Signs in with email and password, sends a verification email, then signs out.
    /// Used when sign in fails because the email is not verified.
    func resendVerificationEmail(email: String, password: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        let auth = Auth.auth()
        guard auth.currentUser == nil else { throw AuthServiceError.unexpectedSignedInUser }

        let result = try await auth.signIn(withEmail: email, password: password)
        defer { try? signOutCurrentUser(auth: auth) }

        try await result.user.reload()
        guard !result.user.isEmailVerified else { return }
        try await sendVerificationEmail(to: result.user)
    }

    /// Sends a password reset email to the given address.
    func sendPasswordReset(email: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    /// Sends a password reset email to the current user email.
    /// Works only for email and password accounts.
    /// - Returns: The email address that received the reset email.
    func sendPasswordResetToCurrentUserEmail() async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }

        let providers = user.providerData.map(\.providerID)
        guard providers.contains("password") else {
            throw AuthServiceError.passwordResetUnavailable
        }

        let email = (user.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { throw AuthServiceError.noCurrentUserEmail }

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            logAuth("passwordReset sent email=\(maskedEmail(email))")
            return email
        } catch {
            logAuth("passwordReset failed email=\(maskedEmail(email)) \(describe(error: error))")
            throw error
        }
    }

    /// Sends a verification link for changing the current user email.
    /// The email changes only after the user confirms the link.
    func sendChangeEmailVerification(to newEmail: String) async throws {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }
        guard canChangeEmail else { throw AuthServiceError.emailChangeUnavailable }
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.noCurrentUser }

        let normalizedNewEmail = newEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let currentEmail = (user.email ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard normalizedNewEmail != currentEmail else { throw AuthServiceError.emailUnchanged }

        logAuth(
            "changeEmail start current=\(maskedEmail(currentEmail)) new=\(maskedEmail(normalizedNewEmail)) uid=\(user.uid.prefix(8))"
        )

        do {
            try await sendVerificationEmail(beforeUpdatingEmail: normalizedNewEmail, to: user)
            logAuth(
                "changeEmail verificationSent current=\(maskedEmail(currentEmail)) new=\(maskedEmail(normalizedNewEmail))"
            )
        } catch {
            logAuth(
                "changeEmail failed current=\(maskedEmail(currentEmail)) new=\(maskedEmail(normalizedNewEmail)) \(describe(error: error))"
            )
            throw error
        }
    }

    // MARK: - Private

    /// Signs out Firebase and clears cached Google session.
    private func signOutCurrentUser(auth: Auth) throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }

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

    private func sendVerificationEmail(beforeUpdatingEmail email: String, to user: User) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }
    }

    private func describe(error: Error) -> String {
        let nsError = error as NSError
        return "domain=\(nsError.domain) code=\(nsError.code) message=\(nsError.localizedDescription)"
    }

    private func maskedEmail(_ email: String) -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atIndex = trimmed.firstIndex(of: "@") else { return "***" }
        let name = String(trimmed[..<atIndex])
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        let first = name.first.map(String.init) ?? ""
        return "\(first)***@\(domain)"
    }

    private func logAuth(_ message: String) {
#if DEBUG
        print("[App][Auth][Service] \(message)")
#endif
    }
}

// MARK: - Google

extension FirebaseAuthService {

    /// Runs Google sign in and returns the Firebase user ID.
    /// If a guest user is active, it links Google to keep the same account ID.
    func signInWithGoogle(from viewController: UIViewController, using client: GoogleAuthClient) async throws -> String {
        guard !ProcessInfo.processInfo.isPreview else { throw PreviewAuthError() }

        let tokens = try await client.signIn(from: viewController)
        let credential = GoogleAuthProvider.credential(
            withIDToken: tokens.idToken,
            accessToken: tokens.accessToken
        )

        let auth = Auth.auth()
        if let currentUser = auth.currentUser, currentUser.isAnonymous {
            let linked = try await currentUser.link(with: credential)
            return linked.user.uid
        }

        let result = try await auth.signIn(with: credential)
        return result.user.uid
    }
}
