//
//  PillWhiteButtonStyle.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-09-10.
//

import SwiftUI

/// White capsule button style for primary actions on dark/colored backgrounds.
/// Adds subtle press feedback (scale + shadow). Avoid on light surfaces for contrast.
struct PillWhiteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .background(Capsule().fill(Color.white))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.7)))
            .foregroundStyle(AuthTheme.popcorn)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.05 : 0.12),
                    radius: configuration.isPressed ? 6 : 12,
                    y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// Convenience: `Button("…").buttonStyle(.pillWhite)`
extension ButtonStyle where Self == PillWhiteButtonStyle {
    static var pillWhite: PillWhiteButtonStyle { .init() }
}
