//
//  AuthValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

/// Shared sanitize and validation rules for auth input.
enum AuthValidator {

    // MARK: - Policy

    /// Password limits used by auth forms.
    enum Policy {
        /// Minimum password length.
        static let minLength = 12
    }

    enum Message {
        static let invalidEmail = "Enter a valid email address"
        static let invalidPassword = "Password must be at least \(Policy.minLength) chars and include A-Z, a-z, 0-9"
        static let missingPassword = "Enter your password"
        static let passwordMismatch = "Passwords don't match"
        static let termsRequired = "You must accept the terms to continue"
        static let privacyPolicyRequired = "You must accept the privacy policy to continue"
    }

    // MARK: - Character policy
    private static let allowedEmailCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789@._+-")

    // MARK: - Sanitizers

    /// Lowercases input and keeps only supported email characters.
    static func sanitizedEmail(from email: String) -> String {
        let lowered = email.lowercased()
        let filteredScalars = lowered.unicodeScalars.filter { scalar in
            allowedEmailCharacters.contains(scalar)
        }
        return String(String.UnicodeScalarView(filteredScalars))
    }

    /// Trims edge whitespace and keeps printable ASCII only.
    /// This removes emoji and smart punctuation.
    static func sanitizedPassword(from password: String) -> String {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredScalars = trimmed.unicodeScalars.filter { scalar in
            scalar.isASCII && (0x20...0x7E).contains(scalar.value)
        }
        return String(String.UnicodeScalarView(filteredScalars))
    }

    /// Sanitizes password fields with the same rules.
    static func sanitizedPasswordPair(password: String, confirmPassword: String) -> (password: String, confirmPassword: String) {
        (
            password: sanitizedPassword(from: password),
            confirmPassword: sanitizedPassword(from: confirmPassword)
        )
    }

    // MARK: - Validators

    /// Basic email format check for UI forms.
    static func isValidEmail(_ email: String) -> Bool {
        let cleaned = sanitizedEmail(from: email)
        return !cleaned.isEmpty
        && cleaned.wholeMatch(of: /[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]{2,64}/) != nil
    }

    /// Password check for account creation.
    /// Requires one digit, one lowercase, one uppercase, and min length.
    static func isValidPassword(_ password: String) -> Bool {
        let cleaned = sanitizedPassword(from: password)
        let pattern = #"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{\#(Policy.minLength),}$"#
        return !cleaned.isEmpty && cleaned.wholeMatch(of: try! Regex(pattern)) != nil
    }

    /// Login only checks that password is not empty after sanitize.
    static func isValidLoginPassword(_ password: String) -> Bool {
        !sanitizedPassword(from: password).isEmpty
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
        let sanitized = sanitizedPasswordPair(password: password, confirmPassword: confirmPassword)
        let isMatch = !sanitized.password.isEmpty && sanitized.password == sanitized.confirmPassword
        return (hasTriedSubmit || !sanitized.confirmPassword.isEmpty) && !isMatch ? Message.passwordMismatch : nil
    }

    static func termsHelperText(acceptedTerms: Bool, hasTriedSubmit: Bool) -> String? {
        !acceptedTerms && hasTriedSubmit ? Message.termsRequired : nil
    }

    static func privacyPolicyHelperText(acceptedPrivacyPolicy: Bool, hasTriedSubmit: Bool) -> String? {
        !acceptedPrivacyPolicy && hasTriedSubmit ? Message.privacyPolicyRequired : nil
    }
}
