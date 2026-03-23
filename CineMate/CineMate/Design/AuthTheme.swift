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

/// Shared spacing, corner-radius and size tokens used by reusable UI components.
enum SharedUI {
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 14
        static let sheet: CGFloat = 16
    }

    enum Size {
        static let iconButton: CGFloat = 32
        static let fieldIconTapTarget: CGFloat = 32
        static let posterCompact = CGSize(width: 80, height: 120)
        static let posterCard = CGSize(width: 100, height: 150)
        static let posterGrid = CGSize(width: 120, height: 180)
        static let posterLarge = CGSize(width: 300, height: 450)
    }

    enum Overlay {
        static let cardMaxWidth: CGFloat = 320
        static let cardPadding: CGFloat = 18
        static let dimOpacity: CGFloat = 0.35
    }
}
