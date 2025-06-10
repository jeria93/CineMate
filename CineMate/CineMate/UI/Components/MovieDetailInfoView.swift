//
//  MovieDetailInfoView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-10.
//

import SwiftUI

struct MovieDetailInfoView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(movie.title)
                .font(.largeTitle.bold())

            HStack(spacing: 10) {
                if let releaseDate = movie.realeaseDate {
                    Text("Release: \(releaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let vote = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", vote))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let genres = movie.genres {
                MovieGenresView(genres: genres)
            }

            if let overview = movie.overview {
                Text(overview)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MovieDetailInfoView(movie: PreviewData.starWars)
}
