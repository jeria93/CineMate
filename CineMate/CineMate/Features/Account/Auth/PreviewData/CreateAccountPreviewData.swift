//
//  CreateAccountPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-20.
//

import Foundation

/// **CreateAccountPreviewData**
/// Centralized fixtures for Create Account previews.
/// Provides deterministic values for valid/invalid inputs and server-like errors.
/// Preview-only; not used in production.
enum CreateAccountPreviewData {

    /// Well-formed email that passes basic validation.
    static let validEmail: String = "test@test.com"

    /// Clearly invalid email to trigger client-side validation.
    static let invalidEmail: String = "user"

    /// Strong password example that meets common complexity rules.
    static let strongPassword: String = "Password123!"

    /// Weak password example for negative test scenarios.
    static let weakPassword: String = "play123"

    /// Simulated backend error message (e.g. duplicate email).
    static let remoteErrorText: String = "Email already in use"
}
