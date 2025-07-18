//
//  DiscoverRowPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import Foundation

/// Static preview data for `DiscoverMovieRow`.
///
/// Provides mock movies with and without posters to test layout behavior.
enum DiscoverRowPreviewData {

    /// A movie with a valid poster, used for standard layout preview.
    static let dune = SharedPreviewMovies.dune

    /// A movie without a poster image, used to preview fallback UI state.
    static let posterlessMovie = Movie(
        id: PreviewID.next(),
        title: "Posterless Movie",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )
}
