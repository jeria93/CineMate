//
//  AuthValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

/// A tiny, pure utility for auth input.
/// Cleans email/password and validates them with simple, UI-friendly rules.
/// No side effects; safe to call from anywhere.
enum AuthValidator {

    // MARK: - Policy

    /// Password policy used by the validators.
    enum Policy {
        /// Minimum allowed password length
        static let minLength = 4
        /// Maximum allowed password length
        static let maxLength = 8
    }

    // MARK: - Sanitizers

    /// Removes all Unicode whitespace characters (spaces, tabs, newlines, ZW…).
    /// - Parameter text: Any input string.
    /// - Returns: The same string with every whitespace character removed.
    static func removeAllWhitespace(from text: String) -> String {
        text.filter { !$0.isWhitespace }
    }

    /// Normalizes an email: strips all whitespace, trims edges, and lowercases.
    /// - Parameter email: User-typed email.
    /// - Returns: A cleaned, lowercase email string.
    static func sanitizedEmail(from email: String) -> String {
        removeAllWhitespace(from: email)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    /// Normalizes a password: strips all whitespace and trims edges.
    /// - Parameter password: User-typed password.
    /// - Returns: A cleaned password string.
    static func sanitizedPassword(from password: String) -> String {
        removeAllWhitespace(from: password)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Validators (Swift Regex)

    /// UI-grade email check (not full RFC). Disallows any whitespace.
    /// - Parameter email: Email to validate (will be sanitized first).
    /// - Returns: `true` if email passes a pragmatic pattern, else `false`.
    static func isValidEmail(_ email: String) -> Bool {
        let cleaned = sanitizedEmail(from: email)
        return !cleaned.isEmpty
        && cleaned.wholeMatch(of: /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}/) != nil
    }

    /// Password must have ≥1 digit, ≥1 lowercase, ≥1 uppercase, and length per `Policy`.
    /// Whitespace is not allowed.
    /// - Parameter password: Password to validate (will be sanitized first).
    /// - Returns: `true` if password meets all rules, else `false`.
    static func isValidPassword(_ password: String) -> Bool {
        let cleaned = sanitizedPassword(from: password)
        let pattern = #"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{\#(Policy.minLength),\#(Policy.maxLength)}$"#
        return !cleaned.isEmpty && cleaned.wholeMatch(of: try! Regex(pattern)) != nil
    }

    /// Convenience: both fields must be valid.
    /// - Parameters:
    ///   - email: Candidate email.
    ///   - password: Candidate password.
    /// - Returns: `true` if email and password are both valid.
    static func isValidForm(email: String, password: String) -> Bool {
        isValidEmail(email) && isValidPassword(password)
    }
}
