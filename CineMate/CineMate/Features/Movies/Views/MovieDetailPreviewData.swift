//
//  MovieDetailPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Mocked MovieDetail data for previews.
enum MovieDetailPreviewData {

    static var starWarsDetail: MovieDetail {
        let movie = SharedPreviewMovies.starWars

        return MovieDetail(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
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
