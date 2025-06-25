//
//  PersonMovieCredit.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import Foundation

/// Represents a single movie credit for a specific person (as cast).
/// Example response from TMDB:
/// {
///   "cast": [
///     {
///       "id": 11,
///       "title": "Star Wars: A New Hope",
///       "character": "Luke Skywalker",
///       "release_date": "1977-05-25",
///       "poster_path": "/poster.jpg"
///     },
///     ...
///   ]
/// }

struct PersonMovieCredit: Codable, Identifiable {
    let id: Int
    let title: String?
    let character: String?
    let releaseDate: String?
    let posterPath: String?

    /// Returns a full image URL for the movie poster (w200 size).
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")
    }
}

struct PersonMovieCreditsResponse: Codable {
    let cast: [PersonMovieCredit]
}
