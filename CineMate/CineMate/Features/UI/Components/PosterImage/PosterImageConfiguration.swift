//
//  PosterImageConfiguration.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-27.
//

import SwiftUI

/// Shared layout values for reusable poster image components.
struct PosterImageConfiguration {
    let size: CGSize
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    static let compact = PosterImageConfiguration(
        size: SharedUI.Size.posterCompact,
        cornerRadius: SharedUI.Radius.medium,
        shadowRadius: 4
    )

    static let grid = PosterImageConfiguration(
        size: SharedUI.Size.posterGrid,
        cornerRadius: SharedUI.Radius.medium,
        shadowRadius: 4
    )

    static let large = PosterImageConfiguration(
        size: SharedUI.Size.posterLarge,
        cornerRadius: SharedUI.Radius.medium,
        shadowRadius: 4
    )
}
