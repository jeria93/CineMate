//
//  KnownForPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Provides mock data for `KnownForScrollView` previews.
enum KnownForPreviewData {

    /// Full movie credits (e.g. Star Wars movies).
    static let full = PreviewData.markHamillMovieCredits

    /// Empty list to simulate no results.
    static let empty: [PersonMovieCredit] = []

    /// Partial list with minimal data and no poster.
    static let partial: [PersonMovieCredit] = [
        PersonMovieCredit(
            id: PreviewID.next(),
            title: "Mysterious Adventure",
            character: nil,
            releaseDate: "2025-01-01",
            posterPath: nil,
            popularity: nil
        )
    ]
}
