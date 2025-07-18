//
//  MovieCreditsPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Provides mock MovieCredits data for previews.
enum MovieCreditsPreviewData {

    static func starWarsCredits() -> MovieCredits {
        PreviewID.reset()
        return MovieCredits(
            id: PreviewID.next(),
            cast: [
                CastMember(
                    id: PreviewID.next(),
                    name: "Mark Hamill",
                    character: "Luke Skywalker",
                    profilePath: "/2ZulC2Ccq1yv3pemusks6Zlfy2s.jpg"
                ),
                CastMember(
                    id: PreviewID.next(),
                    name: "Harrison Ford",
                    character: "Han Solo",
                    profilePath: "/zVnHagUvXkR2StdOtquEwsiwSVt.jpg"
                ),
                CastMember(
                    id: PreviewID.next(),
                    name: "Carrie Fisher",
                    character: "Princess Leia",
                    profilePath: "/awb4UqzT6meD3JiQlraIzAqcRtH.jpg"
                ),
                CastMember(
                    id: PreviewID.next(),
                    name: "Chewbacca",
                    character: nil,
                    profilePath: nil
                )
            ],
            crew: [
                CrewMember(
                    id: PreviewID.next(),
                    name: "George Lucas",
                    job: "Director",
                    profilePath: "/mDLDvsx8PaZoEThkBdyaG1JxPdf.jpg"
                ),
                CrewMember(
                    id: PreviewID.next(),
                    name: "Gary Kurtz",
                    job: "Producer",
                    profilePath: "/q6tgPiNqzEOIYmHxMrpWoUirmmu.jpg"
                )
            ]
        )
    }

    static let emptyCredits = MovieCredits(id: 0, cast: [], crew: [])

    static let onlyDirector = MovieCredits(
        id: 1,
        cast: [],
        crew: [
            CrewMember(id: 1, name: "Christopher Nolan", job: "Director", profilePath: nil)
        ]
    )

    static let onlyCast = MovieCredits(
        id: 2,
        cast: [
            CastMember(id: 1, name: "Actor A", character: nil, profilePath: nil),
            CastMember(id: 2, name: "Actor B", character: nil, profilePath: nil)
        ],
        crew: []
    )
}
