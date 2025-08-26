//
//  ResetPasswordPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-24.
//

import Foundation

/// Static sample data used by Xcode Previews for the Reset Password flow.
/// Keeps preview builders small and readable (no literals sprinkled around).
enum ResetPasswordPreviewData {
    /// A syntactically valid email for “filled” previews.
    static let validEmail: String = "user@example.com"

    /// An intentionally invalid email for validation/error previews.
    static let invalidEmail: String = "invalid@"

    /// Human-readable error shown in “server error / network” previews.
    static let networkErrorText: String = "Network error. Check your connection"
}
