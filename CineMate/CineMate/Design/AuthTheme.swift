//
//  AuthTheme.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

/// Auth-specific color tokens.
/// These are layered on top of app-wide color assets to keep auth visuals consistent.
enum AuthTheme {
    static let curtainTop = Color.tmdbNavy
    static let curtainBottom = Color.tmdbBlue
    static let popcorn = Color.appPrimaryAction

    static let cardStroke = Color.white.opacity(0.16)
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

/// App-wide semantic colors backed by Assets.xcassets tokens.
extension Color {
    // Raw TMDB brand colors
    static let tmdbNavy = Color("Brand/TMDB/Navy")
    static let tmdbBlue = Color("Brand/TMDB/Blue")
    static let tmdbGreen = Color("Brand/TMDB/Green")

    // Semantic app tokens
    static let appBackground = Color("App/Background")
    static let appSurface = Color("App/Surface")
    static let appTextPrimary = Color("App/TextPrimary")
    static let appTextSecondary = Color("App/TextSecondary")
    static let appPrimaryAction = Color("App/PrimaryAction")
    static let appPositive = Color("App/Positive")
}
