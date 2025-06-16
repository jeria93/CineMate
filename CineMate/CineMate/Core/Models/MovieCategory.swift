//
//  MovieCategory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

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


