//
//  MovieDetail.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import Foundation

/// Detailed information about a specific movie fetched from TMDB.
/// Endpoint: https://developer.themoviedb.org/reference/movie-details
///
/// **Notes:**
/// - `releaseDate` is in "YYYY-MM-DD" format (string from API).
/// - `runtime` is in minutes.
/// - `voteAverage` is on a 0–10 scale.
/// - `budget` and `revenue` are whole numbers (e.g., USD, no cents).
struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?

    let runtime: Int?
    let budget: Int?
    let revenue: Int?
    let homepage: String?
    let status: String?
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let genres: [Genre]
}

// MARK: - Supporting types

/// A company involved in the production of a movie.
/// Appears in `MovieDetail.productionCompanies`.
struct ProductionCompany: Codable {
    let name: String
}

/// A country where the movie was produced.
/// Appears in `MovieDetail.productionCountries`.
struct ProductionCountry: Codable {
    let name: String
}

// MARK: - Convenience Extensions

extension MovieDetail {
    /// Returns only the genre names as strings.
    var genreNames: [String] {
        genres.map { $0.name }
    }

    /// Creates preview `Genre` objects from the genre names.
    /// Useful in previews or fallback UI when full genre objects are needed.
    var previewGenres: [Genre] {
        genreNames.map { Genre(id: PreviewID.next(), name: $0) }
    }

    /// Human-readable runtime like "1h 32m" or nil if unknown.
    var formattedRuntime: String? {
        guard let minutes = runtime else { return nil }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }

    /// Returns the homepage as a URL if the string is valid.
    var homepageURL: URL? {
        guard
            let homepage,
            let url = URL(string: homepage)
        else { return nil }
        return url
    }
}
