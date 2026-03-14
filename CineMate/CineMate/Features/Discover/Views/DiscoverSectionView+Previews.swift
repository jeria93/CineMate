//
//  DiscoverSectionView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

/// Preview variants for `DiscoverSectionView`.
///
/// Simulates common and edge UI states for horizontal movie sections:
/// - `previewDefault`: Full list of mock movies
/// - `previewEmpty`: No movies available
/// - `previewOneMovie`: Single movie in section
/// - `previewNoPosters`: All movies missing poster images
/// - `previewLongTitles`: Movies with overly long titles
extension DiscoverSectionView {

    /// Preview with standard list of movies.
    ///
    /// Uses `SharedPreviewMovies.moviesList`, which contains deterministic IDs.
    static var previewDefault: some View {
        DiscoverSectionView(
            title: "Top Rated",
            movies: SharedPreviewMovies.moviesList,
            onSeeAllTap: {}
        )
    }

    /// Preview with an empty section (no movies).
    ///
    /// Useful to verify layout behavior when no content is available.
    static var previewEmpty: some View {
        DiscoverSectionView(
            title: "Empty Section",
            movies: [],
            onSeeAllTap: {}
        )
    }

    /// Preview showing only one movie in the section.
    ///
    /// Uses a single item from `SharedPreviewMovies`.
    static var previewOneMovie: some View {
        DiscoverSectionView(
            title: "Just One",
            movies: [SharedPreviewMovies.dune],
            onSeeAllTap: {}
        )
        .padding()
    }

    /// Preview where all movies are missing posters.
    ///
    /// Creates new movie instances with `.posterPath = nil`.
    static var previewNoPosters: some View {
        DiscoverSectionView(
            title: "No Posters",
            movies: SharedPreviewMovies.moviesList.enumerated().map { index, movie in
                Movie(
                    id: PreviewID.scoped(.discover, 200 + index),
                    title: movie.title,
                    overview: movie.overview,
                    posterPath: nil,
                    backdropPath: movie.backdropPath,
                    releaseDate: movie.releaseDate,
                    voteAverage: movie.voteAverage,
                    genres: movie.genres
                )
            },
            onSeeAllTap: {}
        )
        .padding()
    }

    /// Preview with artificially long titles to test line wrapping and overflow handling.
    ///
    /// Uses deterministic IDs to avoid collisions in `ForEach`.
    static var previewLongTitles: some View {
        DiscoverSectionView(
            title: "Long Titles",
            movies: SharedPreviewMovies.moviesList.enumerated().map { index, movie in
                Movie(
                    id: PreviewID.scoped(.discover, 300 + index),
                    title: movie.title + " — This is a very long movie title to test wrapping",
                    overview: movie.overview,
                    posterPath: movie.posterPath,
                    backdropPath: movie.backdropPath,
                    releaseDate: movie.releaseDate,
                    voteAverage: movie.voteAverage,
                    genres: movie.genres
                )
            },
            onSeeAllTap: {}
        )
        .padding()
    }
}
