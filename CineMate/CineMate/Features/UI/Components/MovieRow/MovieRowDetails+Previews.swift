//
//  MovieRowDetails+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Preview variants for `MovieRowDetails`.
///
/// These previews simulate different UI configurations to verify:
/// - Compact layout with minimal spacing
/// - Detailed layout with full text and large fonts
/// - Minimal fallback layout when data is missing
extension MovieRowDetails {

    /// Preview with a compact UI layout.
    ///
    /// Uses smaller fonts, short overview, and tight spacing.
    static var previewCompact: some View {
        MovieRowDetails(
            movie: SharedPreviewMovies.starWars,
            spacing: 5,
            titleFont: .headline,
            overviewFont: .subheadline,
            showFullOverview: false
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Preview with a detailed UI layout.
    ///
    /// Displays full overview text with generous spacing and larger fonts.
    static var previewDetailed: some View {
        MovieRowDetails(
            movie: SharedPreviewMovies.starWars,
            spacing: 16,
            titleFont: .largeTitle.bold(),
            overviewFont: .body,
            showFullOverview: true
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Preview with minimal movie data.
    ///
    /// Tests fallback rendering when key movie data is missing.
    static var previewMinimal: some View {
        MovieRowDetails(
            movie: SharedPreviewMovies.minimalMovie,
            spacing: 8,
            titleFont: .title2,
            overviewFont: .body,
            showFullOverview: false
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Grouped preview displaying all layout types.
    ///
    /// `PreviewID.reset()` is called once to avoid duplicate IDs if any are created dynamically.
    static var preview: some View {
        PreviewID.reset()
        return Group {
            previewCompact
            previewDetailed
            previewMinimal
        }
    }
}
