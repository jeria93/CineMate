//
//  DiscoverPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import Foundation

struct DiscoverPreviewData {
    static let dune = Movie(
        id: 438631,
        title: "Dune",
        overview: "Paul Atreides leads nomadic tribes in a battle to control the desert planet Arrakis.",
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 8.2,
        genres: ["Action", "Adventure", "Sci-Fi"]
    )

    static let oppenheimer = Movie(
        id: 872585,
        title: "Oppenheimer",
        overview: "The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.",
        posterPath: "/ptpr0kGAckfQkJeJIt8st5dglvd.jpg",
        backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
        releaseDate: "2023-07-21",
        voteAverage: 8.6,
        genres: ["Drama", "History"]
    )

    static let interstellar = Movie(
        id: 157336,
        title: "Interstellar",
        overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
        posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
        backdropPath: "/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg",
        releaseDate: "2014-11-07",
        voteAverage: 8.4,
        genres: ["Adventure", "Drama", "Sci-Fi"]
    )

    static let movies: [Movie] = [dune, oppenheimer, interstellar]
}


