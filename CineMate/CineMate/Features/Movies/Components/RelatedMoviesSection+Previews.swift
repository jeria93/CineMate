//
//  RelatedMoviesSection+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension RelatedMoviesSection {

    /// Preview showing a typical list of recommended movies (4 st).
    @MainActor
    static var previewWithMovies: some View {
        RelatedMoviesSection(
            movies: PreviewFactory.recommendedMovies,
            movieViewModel: PreviewFactory.movieListViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing empty state fallback when no movies are available.
    @MainActor
    static var previewEmpty: some View {
        RelatedMoviesSection(
            movies: [],
            movieViewModel: PreviewFactory.movieListViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing layout when only a single recommended movie exists.
    @MainActor
    static var previewSingleMovie: some View {
        RelatedMoviesSection(
            movies: [SharedPreviewMovies.starWars],
            movieViewModel: PreviewFactory.movieListViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing horizontal scroll behavior with many recommended movies.
    @MainActor
    static var previewManyMovies: some View {
        let source = SharedPreviewMovies.moviesList
        let movies = (1...20).map { index in
            let template = source[(index - 1) % source.count]
            return Movie(
                id: PreviewID.scoped(.movieComponents, 300 + index),
                title: "\(template.title) \(index)",
                overview: template.overview,
                posterPath: template.posterPath,
                backdropPath: template.backdropPath,
                releaseDate: template.releaseDate,
                voteAverage: template.voteAverage,
                genres: template.genres
            )
        }

        return RelatedMoviesSection(
            movies: movies,
            movieViewModel: PreviewFactory.movieListViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
