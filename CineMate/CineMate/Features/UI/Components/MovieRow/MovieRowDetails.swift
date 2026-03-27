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
                    .foregroundStyle(Color.appTextSecondary)
            }

            if let releaseDate = movie.releaseDate {
                Text("Release: \(releaseDate)")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            if let voteAverage = movie.voteAverage {
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.appPositive)
                        .font(.caption)

                    Text(String(format: "%.1f", voteAverage))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }
}

#Preview("Compact") {
    MovieRowDetails.previewCompact
}

#Preview("Detailed") {
    MovieRowDetails.previewDetailed
}

#Preview("Fallback / Minimal") {
    MovieRowDetails.previewMinimal
}
