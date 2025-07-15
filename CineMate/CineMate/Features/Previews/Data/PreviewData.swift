//
//  PreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Provides static mock data for SwiftUI previews.
struct PreviewData {
    static let inception = Movie(
        id: 1001,
        title: "Inception",
        overview: "A thief with the rare ability to enter people's dreams and steal their secrets from their subconscious.",
        posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
        backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
        releaseDate: "2010-07-16",
        voteAverage: 8.3,
        genres: ["Action", "Sci-Fi", "Thriller"]
    )

    static let starWars = Movie(
        id: 1002,
        title: "Star Wars: A New Hope",
        overview: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        genres: ["Adventure", "Sci-Fi", "Fantasy"]
    )

    static let matrix = Movie(
        id: 1003,
        title: "The Matrix",
        overview: "A computer hacker learns about the true nature of reality and his role in the war against its controllers.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
        releaseDate: "1999-03-31",
        voteAverage: 8.1,
        genres: ["Action", "Sci-Fi"]
    )

    static let pulpFiction = Movie(
        id: 1004,
        title: "Pulp Fiction",
        overview: "The lives of two mob hitmen, a boxer, a gangster's wife, and a pair of diner bandits intertwine in four tales.",
        posterPath: "/vQWk5YBFWF4bZaofAbv0tShwBvQ.jpg",
        backdropPath: "/u8XsWsS8sWhtSlTqrcfjC1lm1kU.jpg",
        releaseDate: "1994-09-10",
        voteAverage: 8.5,
        genres: ["Crime", "Drama"]
    )

    static let moviesList: [Movie] = [
        inception,
        starWars,
        matrix,
        pulpFiction
    ]

    static let starWarsCredits = MovieCredits(
        id: 11,
        cast: [
            CastMember(
                id: 1,
                name: "Mark Hamill",
                character: "Luke Skywalker",
                profilePath: "/2ZulC2Ccq1yv3pemusks6Zlfy2s.jpg"
            ),
            CastMember(
                id: 2,
                name: "Harrison Ford",
                character: "Han Solo",
                profilePath: "/zVnHagUvXkR2StdOtquEwsiwSVt.jpg"
            ),
            CastMember(
                id: 3,
                name: "Carrie Fisher",
                character: "Princess Leia",
                profilePath: "/awb4UqzT6meD3JiQlraIzAqcRtH.jpg"
            ),
            CastMember(
                id: 4,
                name: "Chewbacca",
                character: nil,
                profilePath: nil
            )
        ],
        crew: [
            CrewMember(id: 100, name: "George Lucas", job: "Director", profilePath: "/mDLDvsx8PaZoEThkBdyaG1JxPdf.jpg"),
            CrewMember(id: 101, name: "Gary Kurtz", job: "Producer", profilePath: "/q6tgPiNqzEOIYmHxMrpWoUirmmu.jpg")
        ]
    )

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

    static let markHamillMovies: [Movie] = [
        Movie(
            id: 1977,
            title: "Star Wars: A New Hope",
            overview: "A young farm boy becomes a Jedi.",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: nil,
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            genres: ["Sci-Fi", "Adventure"]
        ),
        Movie(
            id: 1980,
            title: "Star Wars: The Empire Strikes Back",
            overview: "The Rebellion suffers major setbacks.",
            posterPath: "/94d3yJEaSy9XrJtCzU1bjjJFqzI.jpg",
            backdropPath: nil,
            releaseDate: "1980-05-21",
            voteAverage: 8.4,
            genres: ["Sci-Fi", "Action"]
        ),
        Movie(
            id: 1983,
            title: "Star Wars: Return of the Jedi",
            overview: "The final confrontation with the Empire.",
            posterPath: "/aP6gk1vF5lLrBLfe3G3Oe00syVn.jpg",
            backdropPath: nil,
            releaseDate: "1983-05-25",
            voteAverage: 8.0,
            genres: ["Sci-Fi", "Fantasy"]
        )
    ]

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

    static let markHamill = starWarsCredits.cast.first { $0.name == "Mark Hamill" }!

    static let unknownActor = CastMember(
        id: 2,
        name: "Unknown Actor",
        character: nil,
        profilePath: nil
    )

    static let longNameActor = CastMember(
        id: 3,
        name: "This is a really really really long actor name",
        character: "Extraordinary Sidekick of Episode 47 Part 3",
        profilePath: nil
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

    static let minimalMovie = Movie(
        id: 1999,
        title: "Unknown Title",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )
}
