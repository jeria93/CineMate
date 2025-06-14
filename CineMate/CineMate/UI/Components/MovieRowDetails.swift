//
//  MovieRowDetails.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieRowDetails: View {

    let movie: Movie
    let spacing: CGFloat
    let titleFont: Font
    let overviewFont: Font
    let showFullOverview: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {

            Text(movie.title)
                .font(titleFont)

            if let overview = movie.overview {
                Text(overview)
                    .font(overviewFont)
                    .lineLimit(showFullOverview ? nil : 3)
                    .foregroundColor(.secondary)
            }

            if let releaseDate = movie.releaseDate {
                Text("Release: \(releaseDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let voteAverage = movie.voteAverage {
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(String(format: "%.1f", voteAverage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview("Compact layout") {
    MovieRowDetails(
        movie: PreviewData.starWars,
        spacing: 5,
        titleFont: .headline,
        overviewFont: .subheadline,
        showFullOverview: false
    )
}

#Preview("Detailed layout") {
    MovieRowDetails(
        movie: PreviewData.starWars,
        spacing: 16,
        titleFont: .largeTitle.bold(),
        overviewFont: .body,
        showFullOverview: true
    )
}
