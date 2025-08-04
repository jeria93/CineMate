//
//  DiscoverFilterProvider.swift
//  CineMate
//

import Foundation

/// Provides preconfigured `DiscoverFilter` instances for each Discover section.
///
/// This helper centralizes filter logic for consistency across the app.
/// Using these methods ensures that Discover sections like Popular, Upcoming,
/// and Horror always apply the same sorting and filtering rules.
///
/// **Examples:**
/// ```swift
/// let filter = DiscoverFilterProvider.filter(for: "Upcoming")
/// let movies = await repository.discoverMovies(filters: filter.queryItems)
/// ```
enum DiscoverFilterProvider {

    /// Returns a `DiscoverFilter` configured for the given section.
    ///
    /// - Parameter section: The Discover section name (e.g., `"Popular"`, `"Upcoming"`).
    /// - Returns: A `DiscoverFilter` with appropriate configuration.
    ///
    /// **Note:** Unknown section names fall back to a default empty filter.
    static func filter(for section: String) -> DiscoverFilter {
        switch section {
        case "Popular":
            return makePopularFilter()
        case "Top Rated":
            return makeTopRatedFilter()
        case "Trending":
            return makeTrendingFilter()
        case "Upcoming":
            return makeUpcomingFilter()
        case "Now Playing":
            return makeNowPlayingFilter()
        case "Horror":
            return makeHorrorFilter()
        default:
            return DiscoverFilter()
        }
    }

    // MARK: - Private Builders

    /// Returns a filter for the "Popular" section, sorted by descending popularity.
    private static func makePopularFilter() -> DiscoverFilter {
        DiscoverFilter(sortOption: .popularityDesc)
    }

    /// Returns a filter for the "Top Rated" section.
    /// - Sorted by highest vote average.
    /// - Limited to the current year and movies rated ≥ 7.0.
    private static func makeTopRatedFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .voteAverageDesc,
            releaseYear: DateHelper.currentYearString(),
            minVoteAverage: 7.0
        )
    }

    /// Returns a filter for the "Trending" section, using popularity descending.
    private static func makeTrendingFilter() -> DiscoverFilter {
        DiscoverFilter(sortOption: .popularityDesc)
    }

    /// Returns a filter for the "Upcoming" section.
    /// - Sorted by popularity descending.
    /// - Limited to the current year for relevance.
    private static func makeUpcomingFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            releaseYear: DateHelper.currentYearString()
        )
    }

    /// Returns a filter for the "Now Playing" section.
    /// - Sorted by popularity descending.
    /// - Limited to the current year and movies rated ≥ 5.0.
    /// - Excludes adult content.
    private static func makeNowPlayingFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            releaseYear: DateHelper.currentYearString(),
            minVoteAverage: 5.0,
            includeAdult: false
        )
    }

    /// Returns a filter for the "Horror" section, using the Horror genre (ID 27).
    private static func makeHorrorFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            withGenres: GenreIDs.horror
        )
    }
}

/// Contains genre ID groups for easy reuse in filters.
enum GenreIDs {
    static let horror = [27]
    // Add more genre groups here as needed
}
