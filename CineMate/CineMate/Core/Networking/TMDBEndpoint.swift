//
//  TMDBEndpoint.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-16.
//

import Foundation

/// Enum containing all TMDB endpoints used in the app.
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
    case search
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

    func url(baseURL: URL, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw TMDBError.badURL
        }

        let normalizedBasePath = components.path.hasSuffix("/")
            ? String(components.path.dropLast())
            : components.path
        components.path = normalizedBasePath + path

        let cleanedQueryItems = sanitize(queryItems: queryItems)
        if !cleanedQueryItems.isEmpty {
            components.queryItems = cleanedQueryItems
        }

        guard let url = components.url else {
            throw TMDBError.badURL
        }
        return url
    }

    func makeRequest(
        baseURL: URL,
        queryItems: [URLQueryItem] = [],
        bearerToken: String
    ) throws -> URLRequest {
        let url = try url(baseURL: baseURL, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}

private extension TMDBEndpoint {
    func sanitize(queryItems: [URLQueryItem]) -> [URLQueryItem] {
        queryItems.compactMap { item in
            let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return nil }

            guard let rawValue = item.value else {
                return URLQueryItem(name: name, value: nil)
            }

            let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { return nil }
            return URLQueryItem(name: name, value: value)
        }
    }
}
