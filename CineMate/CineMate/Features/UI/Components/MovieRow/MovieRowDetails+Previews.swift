//
//  MovieRowDetails+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieRowDetails {
    static var previewCompact: some View {
        MovieRowDetails(
            movie: PreviewData.starWars,
            spacing: 5,
            titleFont: .headline,
            overviewFont: .subheadline,
            showFullOverview: false
        )
    }

    static var previewDetailed: some View {
        MovieRowDetails(
            movie: PreviewData.starWars,
            spacing: 16,
            titleFont: .largeTitle.bold(),
            overviewFont: .body,
            showFullOverview: true
        )
    }

    static var preview: some View {
        Group {
            previewCompact
            previewDetailed
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(.systemGroupedBackground))
    }
}
