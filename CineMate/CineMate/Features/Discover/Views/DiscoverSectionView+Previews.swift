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
    /// Uses `SharedPreviewMovies.moviesList` which contains a fixed set of
    /// mock movies created with `PreviewID.next()`.
    /// No need to call `PreviewID.reset()` here.
    static var previewDefault: some View {
        DiscoverSectionView(
            title: "Top Rated",
            movies: SharedPreviewMovies.moviesList
        )
    }

    /// Preview with an empty section (no movies).
    ///
    /// Useful to verify layout behavior when no content is available.
    static var previewEmpty: some View {
        DiscoverSectionView(
            title: "Empty Section",
            movies: []
        )
    }

    /// Preview showing only one movie in the section.
    ///
    /// Uses a single item from `SharedPreviewMovies`.
    static var previewOneMovie: some View {
        DiscoverSectionView(
            title: "Just One",
            movies: [SharedPreviewMovies.dune]
        )
        .padding()
    }

    /// Preview where all movies are missing posters.
    ///
    /// Creates new movie instances with `.posterPath = nil`.
    /// `PreviewID.reset()` is required here to avoid ID conflicts.
    static var previewNoPosters: some View {
        PreviewID.reset()
        return DiscoverSectionView(
            title: "No Posters",
            movies: SharedPreviewMovies.moviesList.map {
                Movie(
                    id: PreviewID.next(),
                    title: $0.title,
                    overview: $0.overview,
                    posterPath: nil,
                    backdropPath: $0.backdropPath,
                    releaseDate: $0.releaseDate,
                    voteAverage: $0.voteAverage,
                    genres: $0.genres
                )
            }
        )
        .padding()
    }

    /// Preview with artificially long titles to test line wrapping and overflow handling.
    ///
    /// `PreviewID.reset()` is needed because new `Movie` instances are created with fresh IDs.
    static var previewLongTitles: some View {
        PreviewID.reset()
        return DiscoverSectionView(
            title: "Long Titles",
            movies: SharedPreviewMovies.moviesList.map {
                Movie(
                    id: PreviewID.next(),
                    title: $0.title + " — This is a very long movie title to test wrapping",
                    overview: $0.overview,
                    posterPath: $0.posterPath,
                    backdropPath: $0.backdropPath,
                    releaseDate: $0.releaseDate,
                    voteAverage: $0.voteAverage,
                    genres: $0.genres
                )
            }
        )
        .padding()
    }
}
