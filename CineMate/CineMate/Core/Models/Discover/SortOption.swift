//
//  SortOption.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import Foundation

/// Enum for all valid sort options supported by TMDB's /discover/movie endpoint.
enum SortOption: String, CaseIterable, Identifiable {
    case popularityDesc = "popularity.desc"
    case popularityAsc = "popularity.asc"
    case voteAverageDesc = "vote_average.desc"
    case voteAverageAsc = "vote_average.asc"
    case releaseDateDesc = "primary_release_date.desc"
    case releaseDateAsc = "primary_release_date.asc"

    var id: String { rawValue }

    /// A human-friendly label for UI display.
    var label: String {
        switch self {
        case .popularityDesc: return "Popularity ↓"
        case .popularityAsc: return "Popularity ↑"
        case .voteAverageDesc: return "Rating ↓"
        case .voteAverageAsc: return "Rating ↑"
        case .releaseDateDesc: return "Release Date ↓"
        case .releaseDateAsc: return "Release Date ↑"
        }
    }
}
