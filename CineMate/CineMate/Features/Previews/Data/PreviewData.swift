//
//  PreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Provides static mock data for SwiftUI previews.
struct PreviewData {

    /// Returns a version of `starWarsCredits` with unique IDs for preview use.
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

    static let sampleVideos: [MovieVideo] = [
        MovieVideo(
            id: "12345",
            key: "dQw4w9WgXcQ",
            name: "Official Trailer",
            site: "YouTube",
            type: "Trailer"
        )
    ]

    static let starWarsDetail = MovieDetail(
        id: 11,
        runtime: 121,
        budget: 11000000,
        revenue: 775398007,
        homepage: "http://www.starwars.com/films/star-wars-episode-iv-a-new-hope",
        status: "Released",
        productionCompanies: [
            ProductionCompany(name: "Lucasfilm Ltd."),
            ProductionCompany(name: "Twentieth Century Fox")
        ],
        productionCountries: [
            ProductionCountry(name: "United States of America")
        ],
        genres: Genre.all
    )

    static let emptyDetail = MovieDetail(
        id: 0,
        runtime: nil,
        budget: nil,
        revenue: nil,
        homepage: nil,
        status: nil,
        productionCompanies: [],
        productionCountries: [],
        genres: []
    )

    static let markHamillMovieCredits: [PersonMovieCredit] = [
        PersonMovieCredit(
            id: 1977,
            title: "Star Wars: A New Hope",
            character: "Luke Skywalker",
            releaseDate: "1977-05-25",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            popularity: 95.0
        ),
        PersonMovieCredit(
            id: 1980,
            title: "The Empire Strikes Back",
            character: "Luke Skywalker",
            releaseDate: "1980-05-21",
            posterPath: "/nNAeTmF4CtdSgMDplXTDPOpYzsX.jpg",
            popularity: 90.5
        ),
        PersonMovieCredit(
            id: 1983,
            title: "Return of the Jedi",
            character: "Luke Skywalker",
            releaseDate: "1983-05-25",
            posterPath: "/jQYlydvHm3kUix1f8prMucrplhm.jpg",
            popularity: 88.2
        )
    ]

    static let markHamillPersonDetail = PersonDetail(
        id: 1,
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

    static let directorNolan = CrewMember(
        id: 525,
        name: "Christopher Nolan",
        job: "Director",
        profilePath: "/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg"
    )

    static let emptyPersonDetail = PersonDetail(
        id: 0,
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

    static let mockWatchProviders: [WatchProvider] = [
        WatchProvider(providerId: 8, providerName: "Netflix", logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg"),
        WatchProvider(providerId: 9, providerName: "Amazon Prime Video", logoPath: "/emthp39XA2YScoYL1p0sdbAH2WA.jpg"),
        WatchProvider(providerId: 337, providerName: "Disney+", logoPath: "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg")
    ]

    static let mockWatchProviderRegion = WatchProviderRegion(
        link: "https://www.themoviedb.org/movie/11/watch",
        flatrate: mockWatchProviders,
        rent: nil,
        buy: nil
    )

}
