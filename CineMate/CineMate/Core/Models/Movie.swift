//
//  Movie.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Represents a movie returned by various movie list endpoints.
/// Example endpoints:
/// - Popular: https://developer.themoviedb.org/reference/movie-popular-list
/// - Top Rated: https://developer.themoviedb.org/reference/movie-top-rated-list
/// - Trending: https://developer.themoviedb.org/reference/trending-movies
struct Movie: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genres: [String]?

    var posterSmallURL: URL? {
        TMDBImageHelper.url(for: posterPath, size: .w185)
    }

    var posterLargeURL: URL? {
        TMDBImageHelper.url(for: posterPath, size: .w500)
    }
}

struct MovieResult: Codable {
    let results: [Movie]
}

extension Movie {
    var tmdbURL: URL {
        URL(string: "https://www.themoviedb.org/movie/\(id)")!
    }
}
