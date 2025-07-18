//
//  PersonPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Mocked person detail and credits for previews
enum PersonPreviewData {

    static let markHamill = PersonDetail(
        id: PreviewID.next(),
        name: "Mark Hamill",
        birthday: "1951-09-25",
        deathday: nil,
        biography: "Mark Hamill is an American actor, best known for playing Luke Skywalker in the Star Wars film series.",
        placeOfBirth: "Oakland, California, USA",
        profilePath: "/zMKcrbRz0JzB7C2KQku8gsGCeFs.jpg",
        imdbId: "nm0000434",
        gender: 2,
        knownForDepartment: "Acting",
        alsoKnownAs: [
            "Mark Richard Hamill",
            "Luke",
            "The Trickster"
        ]
    )

    static let movieCredits: [PersonMovieCredit] = [
        PersonMovieCredit(
            id: PreviewID.next(),
            title: "Star Wars: A New Hope",
            character: "Luke Skywalker",
            releaseDate: "1977-05-25",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            popularity: 95.0
        ),
        PersonMovieCredit(
            id: PreviewID.next(),
            title: "The Empire Strikes Back",
            character: "Luke Skywalker",
            releaseDate: "1980-05-21",
            posterPath: "/nNAeTmF4CtdSgMDplXTDPOpYzsX.jpg",
            popularity: 90.5
        ),
        PersonMovieCredit(
            id: PreviewID.next(),
            title: "Return of the Jedi",
            character: "Luke Skywalker",
            releaseDate: "1983-05-25",
            posterPath: "/jQYlydvHm3kUix1f8prMucrplhm.jpg",
            popularity: 88.2
        )
    ]

    static let emptyDetail = PersonDetail(
        id: PreviewID.next(),
        name: "Unknown",
        birthday: nil,
        deathday: nil,
        biography: nil,
        placeOfBirth: nil,
        profilePath: nil,
        imdbId: nil,
        gender: nil,
        knownForDepartment: nil,
        alsoKnownAs: []
    )
}
