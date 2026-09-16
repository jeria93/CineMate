//
//  MovieCreditsPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Catalog-backed credits and isolated empty-state fixtures for previews.
enum MovieCreditsPreviewData {

    /// Returns catalog credits for a movie, or an empty state for an unknown ID.
    static func starWarsCredits(movieId: Int = SharedPreviewMovies.starWars.id) -> MovieCredits {
        DemoCatalog.credits(for: movieId) ?? emptyCredits
    }

    static let emptyCredits = MovieCredits(
        id: PreviewID.scoped(.movieCredits, 900),
        cast: [],
        crew: []
    )

    static let onlyDirector = MovieCredits(
        id: PreviewID.scoped(.movieCredits, 901),
        cast: [],
        crew: [
            CrewMember(
                id: PreviewID.scoped(.movieCredits, 201),
                name: "Christopher Nolan",
                job: "Director",
                profilePath: nil
            )
        ]
    )

    static let onlyCast = MovieCredits(
        id: PreviewID.scoped(.movieCredits, 902),
        cast: [
            CastMember(
                id: PreviewID.scoped(.movieCredits, 301),
                name: "Actor A",
                character: nil,
                profilePath: nil
            ),
            CastMember(
                id: PreviewID.scoped(.movieCredits, 302),
                name: "Actor B",
                character: nil,
                profilePath: nil
            )
        ],
        crew: []
    )
}
