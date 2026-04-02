//
//  DiscoverFilterProvider.swift
//  CineMate
//

import Foundation

/// Typed section identifiers for Discover.
enum DiscoverSectionKind: String, CaseIterable, Identifiable {
    case topRated
    case popular
    case nowPlaying
    case trending
    case upcoming
    case horror

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topRated:
            return "Top Rated"
        case .popular:
            return "Popular"
        case .nowPlaying:
            return "Now Playing"
        case .trending:
            return "Trending"
        case .upcoming:
            return "Upcoming"
        case .horror:
            return "Horror"
        }
    }
}

/// View-ready section model to keep Discover view rendering simple.
struct DiscoverSectionState: Identifiable, Equatable {
    let kind: DiscoverSectionKind
    let movies: [Movie]

    var id: DiscoverSectionKind { kind }
    var title: String { kind.title }
}

/// Provides preconfigured Discover filters per section.
enum DiscoverFilterProvider {
    static func filter(
        for section: DiscoverSectionKind,
        selectedGenreId: Int? = nil,
        referenceDate: Date = Date()
    ) -> DiscoverFilter {
        let today = dateString(from: referenceDate)
        let genres = mergedGenres(for: section, selectedGenreId: selectedGenreId)

        switch section {
        case .topRated:
            return DiscoverFilter(
                sortOption: .voteAverageDesc,
                withGenres: genres,
                minVoteAverage: 7.0,
                minVoteCount: 200,
                includeAdult: false
            )
        case .popular:
            return DiscoverFilter(
                sortOption: .popularityDesc,
                withGenres: genres,
                includeAdult: false
            )
        case .nowPlaying:
            return DiscoverFilter(
                sortOption: .releaseDateDesc,
                withGenres: genres,
                primaryReleaseDateGTE: dateString(daysOffset: -90, from: referenceDate),
                primaryReleaseDateLTE: today,
                minVoteAverage: 5.0,
                includeAdult: false
            )
        case .trending:
            return DiscoverFilter(
                sortOption: .popularityDesc,
                withGenres: genres,
                primaryReleaseDateGTE: dateString(yearsOffset: -5, from: referenceDate),
                minVoteAverage: 5.0,
                includeAdult: false
            )
        case .upcoming:
            return DiscoverFilter(
                sortOption: .releaseDateAsc,
                withGenres: genres,
                primaryReleaseDateGTE: today,
                includeAdult: false
            )
        case .horror:
            return DiscoverFilter(
                sortOption: .popularityDesc,
                withGenres: genres,
                includeAdult: false
            )
        }
    }

    static func section(for title: String) -> DiscoverSectionKind? {
        DiscoverSectionKind.allCases.first { $0.title == title }
    }
}

private extension DiscoverFilterProvider {
    enum GenreIDs {
        static let horror = 27
    }

    static func mergedGenres(for section: DiscoverSectionKind, selectedGenreId: Int?) -> [Int] {
        var genres = [Int]()

        if section == .horror {
            genres.append(GenreIDs.horror)
        }

        if let selectedGenreId, !genres.contains(selectedGenreId) {
            genres.append(selectedGenreId)
        }

        return genres
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    static func dateString(daysOffset: Int, from referenceDate: Date) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: referenceDate) ?? referenceDate
        return dateString(from: date)
    }

    static func dateString(yearsOffset: Int, from referenceDate: Date) -> String {
        let date = Calendar.current.date(byAdding: .year, value: yearsOffset, to: referenceDate) ?? referenceDate
        return dateString(from: date)
    }
}
