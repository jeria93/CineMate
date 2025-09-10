//
//  AuthTheme.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

/// Auth-specific color tokens (cinema “curtain” + “popcorn” accent).
/// Scope to auth screens,  if reused broadly, promote to app-wide design tokens.
enum AuthTheme {
    static let curtainTop    = Color(red: 0.10, green: 0.02, blue: 0.05) // #1A000D
    static let curtainBottom = Color(red: 0.24, green: 0.05, blue: 0.07) // #3D0C12
    static let popcorn       = Color(red: 0.96, green: 0.77, blue: 0.09) // #F5C518

    static let cardStroke    = Color.white.opacity(0.12)
    static let iconOnCurtain = Color.white.opacity(0.95)
}
