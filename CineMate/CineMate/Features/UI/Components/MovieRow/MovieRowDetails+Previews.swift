//
//  MovieRowDetails+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieRowDetails {
    /// Shows a compact layout with short overview and small fonts
    static var previewCompact: some View {
        MovieRowDetails(
            movie: PreviewData.starWars,
            spacing: 5,
            titleFont: .headline,
            overviewFont: .subheadline,
            showFullOverview: false
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Shows a detailed layout with full overview and larger fonts
    static var previewDetailed: some View {
        MovieRowDetails(
            movie: PreviewData.starWars,
            spacing: 16,
            titleFont: .largeTitle.bold(),
            overviewFont: .body,
            showFullOverview: true
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Shows a fallback state with missing optional data
    static var previewMinimal: some View {
        MovieRowDetails(
            movie: PreviewData.minimalMovie,
            spacing: 8,
            titleFont: .title2,
            overviewFont: .body,
            showFullOverview: false
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// Shows all previews in one group for quick visual inspection
    static var preview: some View {
        Group {
            previewCompact
            previewDetailed
            previewMinimal
        }
    }
}
