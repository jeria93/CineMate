//
//  AuthValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

/// Shared validation rules and email normalization for auth input.
enum AuthValidator {

    // MARK: - Policy

    enum Policy {
        static let minLength = 12
    }

    enum Message {
        static let invalidEmail = "Enter a valid email address"
        static let invalidPassword = "Use at least \(Policy.minLength) characters with uppercase, lowercase, and a number"
        static let missingPassword = "Enter your password"
        static let passwordMismatch = "Passwords don't match"
        static let termsRequired = "You must accept the terms to continue"
        static let privacyPolicyRequired = "You must accept the privacy policy to continue"
    }

    private static let allowedEmailCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789@._+-")

    // MARK: - Normalization

    /// Lowercases input and keeps only supported email characters.
    static func sanitizedEmail(from email: String) -> String {
        let lowered = email.lowercased()
        let filteredScalars = lowered.unicodeScalars.filter { scalar in
            allowedEmailCharacters.contains(scalar)
        }
        return String(String.UnicodeScalarView(filteredScalars))
    }

    // MARK: - Validators

    /// Basic email format check for UI forms.
    static func isValidEmail(_ email: String) -> Bool {
        let cleaned = sanitizedEmail(from: email)
        return !cleaned.isEmpty
        && cleaned.wholeMatch(of: /[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]{2,64}/) != nil
    }

    /// Validates new passwords without modifying them.
    /// Requires an ASCII digit, lowercase letter, uppercase letter, and minimum length.
    static func isValidPassword(_ password: String) -> Bool {
        guard password.count >= Policy.minLength else { return false }

        let scalars = password.unicodeScalars
        let hasUppercase = scalars.contains { (0x41...0x5A).contains($0.value) }
        let hasLowercase = scalars.contains { (0x61...0x7A).contains($0.value) }
        let hasNumber = scalars.contains { (0x30...0x39).contains($0.value) }
        return hasUppercase && hasLowercase && hasNumber
    }

    /// Login accepts any non-empty password and preserves it exactly.
    static func isValidLoginPassword(_ password: String) -> Bool {
        !password.isEmpty
    }

    static func emailHelperText(email: String, hasTriedSubmit: Bool) -> String? {
        hasTriedSubmit && !isValidEmail(email) ? Message.invalidEmail : nil
    }

    static func passwordHelperText(password: String, hasTriedSubmit: Bool) -> String? {
        hasTriedSubmit && !isValidPassword(password) ? Message.invalidPassword : nil
    }

    static func loginPasswordHelperText(password: String, hasTriedSubmit: Bool) -> String? {
        hasTriedSubmit && !isValidLoginPassword(password) ? Message.missingPassword : nil
    }

    static func confirmPasswordHelperText(
        password: String,
        confirmPassword: String,
        hasTriedSubmit: Bool
    ) -> String? {
        let isMatch = !password.isEmpty && password == confirmPassword
        return (hasTriedSubmit || !confirmPassword.isEmpty) && !isMatch ? Message.passwordMismatch : nil
    }

    static func termsHelperText(acceptedTerms: Bool, hasTriedSubmit: Bool) -> String? {
        !acceptedTerms && hasTriedSubmit ? Message.termsRequired : nil
    }

    static func privacyPolicyHelperText(acceptedPrivacyPolicy: Bool, hasTriedSubmit: Bool) -> String? {
        !acceptedPrivacyPolicy && hasTriedSubmit ? Message.privacyPolicyRequired : nil
    }
}
