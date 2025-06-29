//
//  MovieRowView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

extension MovieRowView {
    static var preview: some View {
        Group {
            previewDefault
            previewNoPoster
            previewNoOverview
            previewLongOverview
            previewMinimalData
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(.systemGroupedBackground))
    }

    static var previewDefault: some View {
        MovieRowView(movie: PreviewData.starWars)
    }

    static var previewNoPoster: some View {
        let movie = PreviewData.starWars
        return MovieRowView(
            movie: Movie(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                posterPath: nil,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
    }

    static var previewNoOverview: some View {
        let movie = PreviewData.starWars
        return MovieRowView(
            movie: Movie(
                id: movie.id,
                title: movie.title,
                overview: nil,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
    }

    static var previewLongOverview: some View {
        let movie = PreviewData.starWars
        return MovieRowView(
            movie: Movie(
                id: movie.id,
                title: movie.title,
                overview: String(repeating: movie.overview ?? "No overview. ", count: 10),
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                genres: movie.genres
            )
        )
    }

    static var previewMinimalData: some View {
        MovieRowView(
            movie: Movie(
                id: 999,
                title: "Unknown Movie",
                overview: nil,
                posterPath: nil,
                backdropPath: nil,
                releaseDate: nil,
                voteAverage: nil,
                genres: nil
            )
        )
    }
}
