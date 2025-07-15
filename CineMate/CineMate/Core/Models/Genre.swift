//
//  Genre.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-30.
//

import Foundation
/// Represents a single genre used to categorize movies or TV shows.
/// Example: Action, Comedy, Drama, etc.
///
/// API Reference:
/// https://developer.themoviedb.org/reference/genre-movie-list
///
/// This struct is typically used to decode responses from TMDB's `/genre/movie/list`
/// or `/genre/tv/list` endpoints.
struct Genre: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}
