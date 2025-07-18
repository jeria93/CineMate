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
        id: PreviewID.next(),
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
        id: PreviewID.next(),
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
