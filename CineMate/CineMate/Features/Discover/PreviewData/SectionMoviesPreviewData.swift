//
//  SectionMoviesPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation

/// Mock movie data used in `SectionMoviesView` previews.
///
/// Includes 3 well-known movie examples:
/// - Interstellar
/// - Dune
/// - Oppenheimer
///
/// Useful for displaying horizontal scrollable movie sections in SwiftUI.
struct SectionMoviesPreviewData {
    static let interstellar = Movie(
        id: 1,
        title: "Interstellar",
        overview: "Explorers travel through a wormhole in space to ensure humanity's survival.",
        posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
        backdropPath: "/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg",
        releaseDate: "2014-11-07",
        voteAverage: 8.4,
        genres: ["Adventure", "Drama", "Sci-Fi"]
    )

    static let dune = Movie(
        id: 2,
        title: "Dune",
        overview: "Paul Atreides leads desert warriors against interplanetary rivals.",
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 8.2,
        genres: ["Action", "Adventure"]
    )

    static let oppenheimer = Movie(
        id: 3,
        title: "Oppenheimer",
        overview: "The story of J. Robert Oppenheimer and the atomic bomb.",
        posterPath: "/ptpr0kGAckfQkJeJIt8st5dglvd.jpg",
        backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
        releaseDate: "2023-07-21",
        voteAverage: 8.6,
        genres: ["Drama", "History"]
    )

    static let movies = [interstellar, dune, oppenheimer]
}
