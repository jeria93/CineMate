//
//  DiscoverSectionView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

/// Preview variants for `DiscoverSectionView`.
/// Used to test layout and edge cases like missing posters, long titles or empty sections.
extension DiscoverSectionView {

    /// Shows a section with three movies (mocked).
    static var previewDefault: some View {
        DiscoverSectionView(
            title: "Top Rated",
            movies: DiscoverPreviewData.movies
        )
    }

    /// Shows an empty section with no movies.
    static var previewEmpty: some View {
        DiscoverSectionView(
            title: "Empty Section",
            movies: []
        )
    }

    /// Displays a section with only one movie.
    static var previewOneMovie: some View {
        DiscoverSectionView(
            title: "Just One",
            movies: [DiscoverPreviewData.dune]
        )
        .padding()
    }

    /// Displays movies where posterPath is nil, to simulate missing poster images.
    static var previewNoPosters: some View {
        DiscoverSectionView(
            title: "No Posters",
            movies: DiscoverPreviewData.movies.map {
                Movie(
                    id: $0.id,
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

    /// Displays movies with overly long titles to test truncation and wrapping behavior.
    static var previewLongTitles: some View {
        DiscoverSectionView(
            title: "Long Titles",
            movies: DiscoverPreviewData.movies.map {
                Movie(
                    id: $0.id,
                    title: $0.title + " — This is a very long movie title",
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
