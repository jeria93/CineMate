//
//  TMDBEndpoint.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-16.
//

import Foundation

enum TMDBEndpoint {
    case movieDetail(Int)
    case popular
    case topRated
    case trending
    case upcoming
    case credits(Int)
    case videos(Int)
    case recommendations(Int)
    case personDetail(Int)
    case personMovieCredits(Int)

    var path: String {
        switch self {
        case .movieDetail(let id): return "/movie/\(id)"
        case .popular: return "/movie/popular"
        case .topRated: return "/movie/top_rated"
        case .trending: return "/trending/movie/week"
        case .upcoming: return "/movie/upcoming"
        case .credits(let id): return "/movie/\(id)/credits"
        case .videos(let id): return "/movie/\(id)/videos"
        case .recommendations(let id): return "/movie/\(id)/recommendations"
        case .personDetail(let id): return "/person/\(id)"
        case .personMovieCredits(let id): return "/person/\(id)/movie_credits"
        }
    }
}
