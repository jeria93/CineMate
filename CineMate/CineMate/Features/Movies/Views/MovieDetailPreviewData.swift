//
//  MovieDetailPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Mocked MovieDetail data for previews
enum MovieDetailPreviewData {

    static let starWarsDetail = MovieDetail(
        id:           PreviewID.next(),
        title:        "Star Wars – A New Hope",
        overview:     "Luke Skywalker joins forces with a Jedi Knight...",
        posterPath:   "/star_wars_poster.jpg",
        backdropPath: nil,
        releaseDate:  "1977-05-25",
        voteAverage:  8.6,

        runtime: 121,
        budget: 11_000_000,
        revenue: 775_398_007,
        homepage: "https://www.starwars.com/films/star-wars-episode-iv-a-new-hope",
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
        id:           PreviewID.next(),
        title:        "Untitled Movie",
        overview:     nil,
        posterPath:   nil,
        backdropPath: nil,
        releaseDate:  nil,
        voteAverage:  nil,

        runtime: nil,
        budget: nil,
        revenue: nil,
        homepage: nil,
        status: nil,
        productionCompanies: [],
        productionCountries: [],
        genres: []
    )
}
