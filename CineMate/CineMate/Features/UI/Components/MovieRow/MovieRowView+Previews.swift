//
//  MovieRowView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

/// Preview variants for `MovieRowView`.
///
/// Covers common edge cases like missing data, long text or missing posters.
extension MovieRowView {

    static var previewDefault: some View {
        PreviewID.reset()
        return MovieRowView(movie: SharedPreviewMovies.starWars)
            .padding()
            .background(Color(.systemGroupedBackground))
    }

    static var previewNoPoster: some View {
        PreviewID.reset()
        let movie = SharedPreviewMovies.starWars
        return MovieRowView(
            movie: Movie(
                id: PreviewID.next(),
                title: movie.title,
                overview: movie.overview,
                posterPath: nil,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    static var previewNoOverview: some View {
        PreviewID.reset()
        let movie = SharedPreviewMovies.starWars
        return MovieRowView(
            movie: Movie(
                id: PreviewID.next(),
                title: movie.title,
                overview: nil,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    static var previewLongOverview: some View {
        PreviewID.reset()
        let movie = SharedPreviewMovies.starWars
        return MovieRowView(
            movie: Movie(
                id: PreviewID.next(),
                title: movie.title,
                overview: String(repeating: movie.overview ?? "No overview. ", count: 10),
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    static var previewMinimalData: some View {
        PreviewID.reset()
        return MovieRowView(movie: SharedPreviewMovies.minimalMovie)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}
