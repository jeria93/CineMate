//
//  MovieRowDetails.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieRowDetails: View {

    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            Text(movie.title)
                .font(.headline)

            if let overview = movie.overview {
                Text(overview)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
            }

            if let releaseDate = movie.realeaseDate {
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

#Preview {
    MovieRowDetails(movie: PreviewData.starWars)
}
