//
//  SharedPreviewMovies.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-15.
//

import Foundation

/// Shared movie mock data used across multiple previews.
/// This helps avoid ID conflicts and duplicate mock definitions.
enum SharedPreviewMovies {

    static let inception = Movie(
        id: PreviewID.next(),
        title: "Inception",
        overview: "A thief with the rare ability to enter people's dreams and steal secrets from their subconscious.",
        posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
        backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
        releaseDate: "2010-07-16",
        voteAverage: 8.3,
        genres: ["Action", "Sci-Fi", "Thriller"]
    )

    static let interstellar = Movie(
        id: PreviewID.next(),
        title: "Interstellar",
        overview: "Explorers travel through a wormhole in space to ensure humanity's survival.",
        posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
        backdropPath: "/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg",
        releaseDate: "2014-11-07",
        voteAverage: 8.4,
        genres: ["Adventure", "Drama", "Sci-Fi"]
    )

    static let oppenheimer = Movie(
        id: PreviewID.next(),
        title: "Oppenheimer",
        overview: "The story of J. Robert Oppenheimer and the atomic bomb.",
        posterPath: "/ptpr0kGAckfQkJeJIt8st5dglvd.jpg",
        backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
        releaseDate: "2023-07-21",
        voteAverage: 8.6,
        genres: ["Drama", "History"]
    )

    static let starWars = Movie(
        id: PreviewID.next(),
        title: "Star Wars: A New Hope",
        overview: "Luke Skywalker joins forces with Jedi, a Wookiee and two droids to fight the Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        genres: ["Adventure", "Sci-Fi", "Fantasy"]
    )

    static let matrix = Movie(
        id: PreviewID.next(),
        title: "The Matrix",
        overview: "A hacker learns about the true nature of reality and his role in the war against its controllers.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
        releaseDate: "1999-03-31",
        voteAverage: 8.1,
        genres: ["Action", "Sci-Fi"]
    )

    static let dune = Movie(
        id: PreviewID.next(),
        title: "Dune",
        overview: "Paul Atreides leads desert warriors against interplanetary rivals.",
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 8.2,
        genres: ["Action", "Adventure"]
    )

    static let moviesList: [Movie] = [
        inception,
        interstellar,
        oppenheimer,
        starWars,
        matrix,
        dune
    ]

    static let minimalMovie = Movie(
        id: PreviewID.next(),
        title: "Unknown Title",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )

}

/// Preview reset helper for SharedPreviewMovies
extension SharedPreviewMovies {
    /// Resets preview ID state for use in previews involving SharedPreviewMovies
    static func resetIDs() {
        PreviewID.reset()
    }
}
