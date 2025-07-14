//
//  DiscoverFilter.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-08.
//

import Foundation

/// A filter model for building query parameters used with TMDB's `/discover/movie` endpoint.
struct DiscoverFilter: Equatable {
    var sortOption: SortOption = .popularityDesc
    var withGenres: [Int] = []
    var releaseYear: String? = nil
    var minVoteAverage: Double? = nil
    var language: String? = nil
    var includeAdult: Bool = false
    var page: Int = 1

    /// Builds an array of URLQueryItems to be used in network requests to TMDB.
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()

        items.append(.init(name: DiscoverQueryKey.sortBy, value: sortOption.rawValue))

        if !withGenres.isEmpty {
            let genreString = withGenres.map(String.init).joined(separator: ",")
            items.append(.init(name: DiscoverQueryKey.withGenres, value: genreString))
        }

        if let releaseYear {
            items.append(.init(name: DiscoverQueryKey.releaseYear, value: releaseYear))
        }

        if let minVoteAverage {
            items.append(.init(name: DiscoverQueryKey.minVoteAverage, value: "\(minVoteAverage)"))
        }

        if let language {
            items.append(.init(name: DiscoverQueryKey.language, value: language))
        }

        if includeAdult {
            items.append(.init(name: DiscoverQueryKey.includeAdult, value: "true"))
        }

        items.append(.init(name: "page", value: "\(page)"))

        return items
    }
}

// MARK: - Query Keys

private enum DiscoverQueryKey {
    static let sortBy = "sort_by"
    static let withGenres = "with_genres"
    static let releaseYear = "primary_release_year"
    static let minVoteAverage = "vote_average.gte"
    static let language = "language"
    static let includeAdult = "include_adult"
}

/*
 Both do the same work, its a preference thing.
 let genreString = withGenres.map(String.init).joined(separator: ",")
 let genreString = withGenres.map { String($0) }.joined(separator: ",")
 */
