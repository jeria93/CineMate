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
        id: 1,
        title: "Inception",
        overview: "A thief with the rare ability to enter people's dreams and steal their secrets from their subconscious.",
        posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
        backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
        releaseDate: "2010-07-16",
        voteAverage: 8.3,
        genres: ["Action", "Sci-Fi", "Thriller"]
    )
    
    static let starWars = Movie(
        id: 11,
        title: "Star Wars: A New Hope",
        overview: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        genres: ["Adventure", "Sci-Fi", "Fantasy"]
    )
    
    static let matrix = Movie(
        id: 603,
        title: "The Matrix",
        overview: "A computer hacker learns about the true nature of reality and his role in the war against its controllers.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
        releaseDate: "1999-03-31",
        voteAverage: 8.1,
        genres: ["Action", "Sci-Fi"]
    )
    
    static let pulpFiction = Movie(
        id: 680,
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
                profilePath: "/zMKcrbRz0JzB7C2KQku8gsGCeFs.jpg"
            ),
            CastMember(
                id: 2,
                name: "Harrison Ford",
                character: "Han Solo",
                profilePath: "/nCJJ3NVksYNxIzEHcyC1XziwPVj.jpg"
            ),
            CastMember(
                id: 3,
                name: "Carrie Fisher",
                character: "Princess Leia",
                profilePath: "/lKYjvdlhFYnvvldzGfbrL2KkPA3.jpg"
            ),
            CastMember(
                id: 4,
                name: "Chewbacca",
                character: nil,
                profilePath: nil
            )
        ],
        crew: [
            CrewMember(name: "George Lucas", job: "Director"),
            CrewMember(name: "Gary Kurtz", job: "Producer")
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
        ]
    )
    
    static let emptyDetail = MovieDetail(
        id: 0,
        runtime: nil,
        budget: nil,
        revenue: nil,
        homepage: nil,
        status: nil,
        productionCompanies: [],
        productionCountries: []
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
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"
        ),
        PersonMovieCredit(
            id: 1980,
            title: "The Empire Strikes Back",
            character: "Luke Skywalker",
            releaseDate: "1980-05-21",
            posterPath: "/94d3yJEaSy9XrJtCzU1bjjJFqzI.jpg"
        ),
        PersonMovieCredit(
            id: 1983,
            title: "Return of the Jedi",
            character: "Luke Skywalker",
            releaseDate: "1983-05-25",
            posterPath: "/aP6gk1vF5lLrBLfe3G3Oe00syVn.jpg"
        )
    ]
    
    static let markHamillPersonDetail = PersonDetail(
        id: 1,
        name: "Mark Hamill",
        birthday: "1951-09-25",
        deathday: nil,
        biography: "Mark Hamill is an American actor, best known for playing Luke Skywalker.",
        placeOfBirth: "Oakland, California, USA",
        profilePath: "/zMKcrbRz0JzB7C2KQku8gsGCeFs.jpg",
        imdbId: "nm0000434"
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
}
