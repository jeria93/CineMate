//
//  MovieCategory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

/// Represents supported movie categories used in the app.
/// These map to different TMDB endpoints:
/// - popular:    https://developer.themoviedb.org/reference/movie-popular-list
/// - topRated:   https://developer.themoviedb.org/reference/movie-top-rated-list
/// - trending:   https://developer.themoviedb.org/reference/trending-movies
/// - upcoming:   https://developer.themoviedb.org/reference/movie-upcoming-list
enum MovieCategory: CaseIterable {
    case popular
    case topRated
    case trending
    case upcoming
    
    var displayName: String {
        switch self {
        case .popular: return "Popular"
        case .topRated: return "Top Rated"
        case .trending: return "Trending"
        case .upcoming: return "Upcoming"
        }
    }
}


