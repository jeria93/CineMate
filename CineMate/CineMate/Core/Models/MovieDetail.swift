//
//  MovieDetail.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import Foundation

/// Detailed information about a specific movie.
/// Endpoint: https://developer.themoviedb.org/reference/movie-details
struct MovieDetail: Codable {
    let id: Int
    let runtime: Int?
    let budget: Int?
    let revenue: Int?
    let homepage: String?
    let status: String?
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let genres: [Genre]
}

/// A company involved in the production of a movie.
/// Part of: `MovieDetail.productionCompanies`
struct ProductionCompany: Codable {
    let name: String
}

/// A country where the movie was produced.
/// Part of: `MovieDetail.productionCountries`
struct ProductionCountry: Codable {
    let name: String
}

extension MovieDetail {
    var genreNames: [String] {
        genres.map { $0.name }
    }
}
