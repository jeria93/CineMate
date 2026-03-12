//
//  PersonMovieCredit.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import Foundation

/// A movie credit for a person.
/// TMDB endpoint: https://developer.themoviedb.org/reference/person-movie-credits
struct PersonMovieCredit: Codable, Identifiable {
    let id: Int
    let title: String?
    let character: String?
    let releaseDate: String?
    let posterPath: String?
    let popularity: Double?

    /// Unique key for list rendering when duplicates exist.
    var uniqueKey: String { "\(id)-\(character ?? "unknown")-\(releaseDate ?? "unknown")" }

    /// Poster URL in w185 size.
    var posterURL: URL? {
        TMDBImageHelper.url(for: posterPath, size: .w185)
    }

    /// Makes a small movie stub for navigation.
    var asMovie: Movie? {
        guard let title else { return nil }
        return Movie(
            id: id,
            title: title,
            overview: nil,
            posterPath: posterPath,
            backdropPath: nil,
            releaseDate: releaseDate,
            voteAverage: nil,
            genres: nil
        )
    }
}

/// Response model for person movie credits.
/// TMDB endpoint: https://developer.themoviedb.org/reference/person-movie-credits
struct PersonMovieCreditsResponse: Codable {
    let cast: [PersonMovieCredit]
}
