//
//  AuthValidator.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-21.
//

import Foundation

/// Shared auth input validator.
/// This keeps sanitize and validation rules in one place.
enum AuthValidator {
    
    // MARK: - Policy
    
    /// Password rules.
    enum Policy {
        /// Minimum allowed password length
        static let minLength = 4
        /// Maximum allowed password length
        static let maxLength = 8
    }
    
    enum Message {
        static let invalidEmail = "Enter a valid email address"
        static let invalidPassword = "Password must be \(Policy.minLength)-\(Policy.maxLength) chars and include A-Z, a-z, 0-9"
        static let passwordMismatch = "Passwords don't match"
        static let termsRequired = "You must accept the terms to continue"
    }
    
    // MARK: - Sanitizers
    
    /// Removes all whitespace characters.
    static func removeAllWhitespace(from text: String) -> String {
        text.filter { !$0.isWhitespace }
    }
    
    /// Trims and lowercases email input.
    static func sanitizedEmail(from email: String) -> String {
        removeAllWhitespace(from: email)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    /// Trims password input and removes whitespace.
    static func sanitizedPassword(from password: String) -> String {
        removeAllWhitespace(from: password)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Sanitizes password and confirm password together.
    static func sanitizedPasswordPair(password: String, confirmPassword: String) -> (password: String, confirmPassword: String) {
        (
            password: sanitizedPassword(from: password),
            confirmPassword: sanitizedPassword(from: confirmPassword)
        )
    }
    
    // MARK: - Validators (Swift Regex)
    
    /// Simple email check for UI forms.
    static func isValidEmail(_ email: String) -> Bool {
        let cleaned = sanitizedEmail(from: email)
        return !cleaned.isEmpty
        && cleaned.wholeMatch(of: /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}/) != nil
    }
    
    /// Password must include one digit, one lowercase, one uppercase.
    /// Length must match Policy.
    static func isValidPassword(_ password: String) -> Bool {
        let cleaned = sanitizedPassword(from: password)
        let pattern = #"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{\#(Policy.minLength),\#(Policy.maxLength)}$"#
        return !cleaned.isEmpty && cleaned.wholeMatch(of: try! Regex(pattern)) != nil
    }
    
    static func emailHelperText(email: String, hasTriedSubmit: Bool) -> String? {
        hasTriedSubmit && !isValidEmail(email) ? Message.invalidEmail : nil
    }
    
    static func passwordHelperText(password: String, hasTriedSubmit: Bool) -> String? {
        hasTriedSubmit && !isValidPassword(password) ? Message.invalidPassword : nil
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
}
