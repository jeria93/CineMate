//
//  PersonMovieCardPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Mock data used in `PersonMovieCardView` previews.
enum PersonMovieCardPreviewData {

    /// Full valid movie credit.
    static let standard: PersonMovieCredit = PersonMovieCredit(
        id: PreviewID.next(),
        title: "Return of the Jedi",
        character: "Luke Skywalker",
        releaseDate: "1983-05-25",
        posterPath: "/jQYlydvHm3kUix1f8prMucrplhm.jpg",
        popularity: 82.4
    )

    /// Missing poster path.
    static let missingPoster: PersonMovieCredit = PersonMovieCredit(
        id: PreviewID.next(),
        title: "Mystery Movie",
        character: nil,
        releaseDate: "2025-01-01",
        posterPath: nil,
        popularity: nil
    )

    /// Missing title (fallback text shown).
    static let missingTitle: PersonMovieCredit = PersonMovieCredit(
        id: PreviewID.next(),
        title: nil,
        character: "Detective John",
        releaseDate: "2024-12-12",
        posterPath: "/somepath.jpg",
        popularity: 42.0
    )
}
