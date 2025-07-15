//
//  DiscoverFilterProvider.swift
//  CineMate
//

import Foundation

/// Provides preconfigured `DiscoverFilter` instances for each Discover section.
enum DiscoverFilterProvider {

    /// Returns a `DiscoverFilter` customized for the given section title.
    ///
    /// - Parameter section: A string representing the Discover section
    ///   (e.g., "Popular", "Top Rated", "Horror").
    /// - Returns: A `DiscoverFilter` with appropriate configuration.
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

    private static func makePopularFilter() -> DiscoverFilter {
        DiscoverFilter(sortOption: .popularityDesc)
    }

    private static func makeTopRatedFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .voteAverageDesc,
            releaseYear: DateHelper.currentYearString(),
            minVoteAverage: 7.0
        )
    }

    private static func makeTrendingFilter() -> DiscoverFilter {
        DiscoverFilter(sortOption: .popularityDesc)
    }

    private static func makeUpcomingFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            releaseYear: DateHelper.currentYearString()
        )
    }

    private static func makeNowPlayingFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            releaseYear: DateHelper.currentYearString(),
            minVoteAverage: 5.0,
            includeAdult: false
        )
    }

    private static func makeHorrorFilter() -> DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            withGenres: GenreIDs.horror
        )
    }
}

enum GenreIDs {
    static let horror = [27]
    // Add more genre groups here as needed
}
