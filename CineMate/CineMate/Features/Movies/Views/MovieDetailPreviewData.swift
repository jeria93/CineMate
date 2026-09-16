//
//  MovieDetailPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Catalog-backed movie details and isolated empty-state fixtures for previews.
enum MovieDetailPreviewData {

    static var starWarsDetail: MovieDetail {
        DemoCatalog.detail(for: DemoCatalog.starWars.id) ?? emptyDetail
    }

    static var emptyDetail: MovieDetail {
        MovieDetail(
            id: PreviewID.scoped(.movieDetail, 900),
            title: "Untitled Movie",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: nil,
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

    static var recommendedMovies: [Movie] {
        SharedPreviewMovies.moviesList
            .filter { $0.id != SharedPreviewMovies.starWars.id }
            .removingDuplicateIDs()
    }
}
