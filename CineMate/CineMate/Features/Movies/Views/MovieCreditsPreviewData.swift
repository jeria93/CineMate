//
//  MovieCreditsPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Provides mock MovieCredits data for previews.
enum MovieCreditsPreviewData {

    static func starWarsCredits(movieId: Int = SharedPreviewMovies.starWars.id) -> MovieCredits {
        return MovieCredits(
            id: movieId,
            cast: [
                CastMember(
                    id: PreviewID.scoped(.movieCredits, 1),
                    name: "Mark Hamill",
                    character: "Luke Skywalker",
                    profilePath: "/2ZulC2Ccq1yv3pemusks6Zlfy2s.jpg"
                ),
                CastMember(
                    id: PreviewID.scoped(.movieCredits, 2),
                    name: "Harrison Ford",
                    character: "Han Solo",
                    profilePath: "/zVnHagUvXkR2StdOtquEwsiwSVt.jpg"
                ),
                CastMember(
                    id: PreviewID.scoped(.movieCredits, 3),
                    name: "Carrie Fisher",
                    character: "Princess Leia",
                    profilePath: "/awb4UqzT6meD3JiQlraIzAqcRtH.jpg"
                ),
                CastMember(
                    id: PreviewID.scoped(.movieCredits, 4),
                    name: "Chewbacca",
                    character: nil,
                    profilePath: nil
                )
            ],
            crew: [
                CrewMember(
                    id: PreviewID.scoped(.movieCredits, 101),
                    name: "George Lucas",
                    job: "Director",
                    profilePath: "/mDLDvsx8PaZoEThkBdyaG1JxPdf.jpg"
                ),
                CrewMember(
                    id: PreviewID.scoped(.movieCredits, 102),
                    name: "Gary Kurtz",
                    job: "Producer",
                    profilePath: "/q6tgPiNqzEOIYmHxMrpWoUirmmu.jpg"
                )
            ]
        )
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
