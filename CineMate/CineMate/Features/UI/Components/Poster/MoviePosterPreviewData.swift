//
//  MoviePosterPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation

/// Provides reusable `Movie` mock data for `MoviePosterView`
/// Use these static properties to simulate posters with or without images
enum MoviePosterViewPreviewData {

    /// A fully populated Dune movie with valid poster path.
    static let dune = Movie(
        id: PreviewID.next(),
        title: "Dune",
        overview: "Paul Atreides leads nomadic tribes in a battle to control Arrakis.",
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 8.2,
        genres: ["Action", "Adventure", "Sci-Fi"]
    )

    /// Same Dune movie but without a poster path (simulates fallback scenarios).
    static let duneNoPoster = Movie(
        id: PreviewID.next(),
        title: "Dune",
        overview: "Paul Atreides leads nomadic tribes in a battle to control Arrakis.",
        posterPath: nil,
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 8.2,
        genres: ["Action", "Adventure", "Sci-Fi"]
    )
}
