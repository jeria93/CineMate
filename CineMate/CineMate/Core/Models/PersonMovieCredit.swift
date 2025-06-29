//
//  PersonMovieCredit.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import Foundation

/// Represents a single movie credit where a person was cast in a role.
/// Endpoint: https://developer.themoviedb.org/reference/person-movie-credits
struct PersonMovieCredit: Codable, Identifiable {
    let id: Int
    let title: String?
    let character: String?
    let releaseDate: String?
    let posterPath: String?
    let popularity: Double?

    /// A unique identifier combining movie ID and character name.
    /// Used for identifying movies in lists where the same movie may appear multiple times.
    var uniqueKey: String { "\(id)-\(character ?? "unknown")-\(releaseDate ?? "unknown")"}

    /// Returns a full image URL for the movie poster (w185 size).
    var posterURL: URL? {
        TMDBImageHelper.url(for: posterPath, size: .w185)
    }
}

/// Response object from the person movie credits endpoint.
/// Includes all movies a person has acted in (as cast).
/// Endpoint: https://developer.themoviedb.org/reference/person-movie-credits
struct PersonMovieCreditsResponse: Codable {
    let cast: [PersonMovieCredit]
}
