//
//  DiscoverFilter.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-08.
//

import Foundation

/// Filter values for TMDB discover requests.
struct DiscoverFilter: Equatable, Hashable {
    var sortOption: SortOption = .popularityDesc
    var withGenres: [Int] = []
    var releaseYear: String?
    var primaryReleaseDateGTE: String?
    var primaryReleaseDateLTE: String?
    var minVoteAverage: Double?
    var minVoteCount: Int?
    var language: String?
    var includeAdult: Bool = false
    var page: Int = 1

    /// Query items for the discover request.
    var queryItems: [URLQueryItem] {
        buildQueryItems()
    }

    /// Returns the base query items plus extra items.
    func queryItems(adding additionalItems: [URLQueryItem]) -> [URLQueryItem] {
        buildQueryItems() + additionalItems.sanitizedForRequest()
    }

    /// Returns a copy with a safe page number.
    func withPage(_ page: Int) -> DiscoverFilter {
        var updated = self
        updated.page = max(1, page)
        return updated
    }
}

private extension DiscoverFilter {
    func buildQueryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()

        items.append(.init(name: DiscoverQueryKey.sortBy, value: sortOption.rawValue))

        if !withGenres.isEmpty {
            let genreString = withGenres.map(String.init).joined(separator: ",")
            items.append(.init(name: DiscoverQueryKey.withGenres, value: genreString))
        }

        if let releaseYear {
            items.append(.init(name: DiscoverQueryKey.releaseYear, value: releaseYear))
        }

        if let primaryReleaseDateGTE {
            items.append(.init(name: DiscoverQueryKey.primaryReleaseDateGTE, value: primaryReleaseDateGTE))
        }

        if let primaryReleaseDateLTE {
            items.append(.init(name: DiscoverQueryKey.primaryReleaseDateLTE, value: primaryReleaseDateLTE))
        }

        if let minVoteAverage {
            items.append(.init(name: DiscoverQueryKey.minVoteAverage, value: "\(minVoteAverage)"))
        }

        if let minVoteCount {
            items.append(.init(name: DiscoverQueryKey.minVoteCount, value: "\(minVoteCount)"))
        }

        if let language {
            items.append(.init(name: DiscoverQueryKey.language, value: language))
        }

        if includeAdult {
            items.append(.init(name: DiscoverQueryKey.includeAdult, value: "true"))
        }

        items.append(.init(name: DiscoverQueryKey.page, value: "\(page)"))
        return items.sanitizedForRequest()
    }
}

// MARK: - Query Keys

enum DiscoverQueryKey {
    static let sortBy = "sort_by"
    static let withGenres = "with_genres"
    static let releaseYear = "primary_release_year"
    static let primaryReleaseDateGTE = "primary_release_date.gte"
    static let primaryReleaseDateLTE = "primary_release_date.lte"
    static let minVoteAverage = "vote_average.gte"
    static let minVoteCount = "vote_count.gte"
    static let language = "language"
    static let includeAdult = "include_adult"
    static let page = "page"
}
