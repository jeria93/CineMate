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
    case personExternalIDs(Int)
    case watchProviders(Int)
    case search(String)
    case discover
    case nowPlaying
    case movieGenres


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
        case .personExternalIDs(let id): return "/person/\(id)/external_ids"
        case .watchProviders(let id): return "/movie/\(id)/watch/providers"
        case .search: return "/search/movie"
        case .discover: return "/discover/movie"
        case .nowPlaying: return "/movie/now_playing"
        case .movieGenres: return "/genre/movie/list"
        }
    }
}
