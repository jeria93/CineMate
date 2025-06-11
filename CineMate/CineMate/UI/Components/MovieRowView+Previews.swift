//
//  MovieRowView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

#Preview("Default / Working poster") {
    MovieRowView(
        movie: Movie(
            id: 11,
            title: "Star Wars: A New Hope",
            overview: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire.",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            genres: ["Action", "Adventure", "Sci-Fi"]
        )
    )
}

#Preview("No poster available") {
    MovieRowView(
        movie: Movie(
            id: 99,
            title: "No Poster Example",
            overview: "This movie has no poster path – perfect for testing placeholder images.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2023-01-01",
            voteAverage: 7.0,
            genres: ["Drama"]
        )
    )
}

#Preview("Long overview text") {
    MovieRowView(
        movie: Movie(
            id: 100,
            title: "Long Overview Example",
            overview: String(repeating: "A very long description of the movie to test line breaks and layout. ", count: 5),
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: nil,
            releaseDate: "2023-01-01",
            voteAverage: 8.0,
            genres: ["Biography", "History", "Drama"]
        )
    )
}

#Preview("No overview") {
    MovieRowView(
        movie: Movie(
            id: 101,
            title: "No Overview Movie",
            overview: nil,
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: nil,
            releaseDate: "2022-12-12",
            voteAverage: 6.2,
            genres: ["Comedy"]
        )
    )
}

#Preview("Extreme ratings") {
    VStack {
        MovieRowView(
            movie: Movie(
                id: 102,
                title: "Perfect 10",
                overview: "This movie has a perfect score!",
                posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
                backdropPath: nil,
                releaseDate: "2021-11-11",
                voteAverage: 10.0,
                genres: ["Fantasy", "Adventure"]
            )
        )
        MovieRowView(
            movie: Movie(
                id: 103,
                title: "Terrible 1.0",
                overview: "Lowest rated movie ever!",
                posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
                backdropPath: nil,
                releaseDate: "2020-10-10",
                voteAverage: 1.0,
                genres: ["Horror"]
            )
        )
    }
}

#Preview("Dark Mode") {
    MovieRowView(
        movie: Movie(
            id: 11,
            title: "Star Wars: A New Hope",
            overview: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire.",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            genres: ["Action", "Adventure", "Sci-Fi"]
        )
    )
    .preferredColorScheme(.dark)
}
