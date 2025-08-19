//
//  LoginPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation

/// **LoginPreviewData**
/// Static sample credentials and messages for login previews.
/// Keeps fake input consistent across preview scenarios.
enum LoginPreviewData {

    /// Valid email used for “filled & valid” previews
    static let validEmail = "nicholas@example.com"

    /// Intentionally invalid email used for validation/error previews
    static let invalidEmail = "user"

    /// Sample password that passes basic length checks
    static let password = "password123"
    
    /// Human-readable error shown in “error” previews
    static let errorText = "Invalid email or password"
}
