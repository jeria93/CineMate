//
//  DiscoverFilter.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-08.
//

import Foundation

/// A filter model for building query parameters used with TMDB's `/discover/movie` endpoint.
struct DiscoverFilter: Equatable, Hashable {
    var sortOption: SortOption = .popularityDesc
    var withGenres: [Int] = []
    var releaseYear: String?
    var minVoteAverage: Double?
    var language: String?
    var includeAdult: Bool = false
    var page: Int = 1

    /// Builds an array of URLQueryItems to be used in network requests to TMDB.
    var queryItems: [URLQueryItem] {
        buildQueryItems()
    }

    /// Builds query items and appends extra items (for endpoint-specific additions).
    func queryItems(adding additionalItems: [URLQueryItem]) -> [URLQueryItem] {
        buildQueryItems() + sanitize(additionalItems)
    }

    /// Returns a copy of this filter updated with the provided page.
    func withPage(_ page: Int) -> DiscoverFilter {
        var updated = self
        updated.page = max(1, page)
        return updated
    }

    /// Reusable helper for `primary_release_date.gte` query item construction.
    static func primaryReleaseDateGTE(_ date: String) -> URLQueryItem {
        URLQueryItem(name: DiscoverQueryKey.primaryReleaseDateGTE, value: date)
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

        if let minVoteAverage {
            items.append(.init(name: DiscoverQueryKey.minVoteAverage, value: "\(minVoteAverage)"))
        }

        if let language {
            items.append(.init(name: DiscoverQueryKey.language, value: language))
        }

        if includeAdult {
            items.append(.init(name: DiscoverQueryKey.includeAdult, value: "true"))
        }

        items.append(.init(name: DiscoverQueryKey.page, value: "\(page)"))

        return sanitize(items)
    }

    func sanitize(_ items: [URLQueryItem]) -> [URLQueryItem] {
        items.compactMap { item in
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

// MARK: - Query Keys

enum DiscoverQueryKey {
    static let sortBy = "sort_by"
    static let withGenres = "with_genres"
    static let releaseYear = "primary_release_year"
    static let primaryReleaseDateGTE = "primary_release_date.gte"
    static let minVoteAverage = "vote_average.gte"
    static let language = "language"
    static let includeAdult = "include_adult"
    static let page = "page"
}
