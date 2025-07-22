//
//  MovieCredits.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import Foundation

/// Response model for movie credits (cast & crew).
/// Endpoint: https://developer.themoviedb.org/reference/movie-credits
struct MovieCredits: Codable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

/// Represents an actor or actress in a movie's cast list.
/// Part of: `MovieCredits.cast`
struct CastMember: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    var profileURL: URL? {
        TMDBImageHelper.url(for: profilePath, size: .h632)
    }
}

/// Represents a crew member (director, writer etc.) in a movie's crew list.
/// Part of: `MovieCredits.crew`
struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String?
    let profilePath: String?

    var profileURL: URL? {
        TMDBImageHelper.url(for: profilePath, size: .h632)
    }
}
