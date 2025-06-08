//
//  PreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Provides static mock data for SwiftUI previews.
/// Use `inception or star wars` for single item previews and `moviesList` for list previews.
struct PreviewData {
    static let inception = Movie(
        id: 1,
        title: "Inception",
        overview: "A thief with the rare ability to enter people's dreams and steal their secrets from their subconscious.",
        posterPath: "/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg",
        backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
        realeaseDate: "2010-07-16",
        voteAverage: 8.3
    )
    
    static let starWars = Movie(
        id: 11,
        title: "Star Wars: A New Hope",
        overview: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/nrxzUoY5Qj9xiF4I7K5rI1D5GxD.jpg",
        realeaseDate: "1977-05-25",
        voteAverage: 8.2
    )
    
    static let moviesList: [Movie] = [
        inception,
        starWars,
        Movie(
            id: 3,
            title: "Interstellar",
            overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            backdropPath: "/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg",
            realeaseDate: "2014-11-07",
            voteAverage: 8.6
        )
    ]
}
