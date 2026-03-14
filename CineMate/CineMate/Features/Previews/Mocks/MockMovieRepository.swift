//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

/// **MockMovieRepository**
///
/// Provides mocked movie data with simulated network delays for previews and testing.
///
/// ### Responsibilities
/// - Simulate TMDB API calls without real network usage
/// - Introduce small delays to mimic realistic async behavior
/// - Provide predictable static data for all endpoints
///
/// ### Usage
/// ```swift
/// let repository = MockMovieRepository()
/// Task {
///     let movies = try await repository.fetchMovies(category: .popular, page: 1)
/// }
/// ```
final class MockMovieRepository: MovieProtocol {

    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        try await Task.sleep(nanoseconds: Delay.short)

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let allMovies: [Movie]
        if normalizedQuery.isEmpty {
            allMovies = SharedPreviewMovies.moviesList
        } else {
            allMovies = SharedPreviewMovies.moviesList.filter {
                $0.title.lowercased().contains(normalizedQuery)
            }
        }

        let pageSize = 6
        let safePage = max(1, page)
        let startIndex = (safePage - 1) * pageSize
        let pageResults: [Movie]
        if startIndex < allMovies.count {
            let endIndex = min(startIndex + pageSize, allMovies.count)
            pageResults = Array(allMovies[startIndex..<endIndex])
        } else {
            pageResults = []
        }

        let totalPages = max(1, Int(ceil(Double(allMovies.count) / Double(pageSize))))

        return MovieResult(
            page: safePage,
            results: pageResults,
            totalPages: totalPages,
            totalResults: allMovies.count
        )
    }

    // MARK: - Mock Delay Configuration
    /// Centralized mock delays for consistent simulation
    private enum Delay {
        static let veryShort: UInt64 = 150_000_000 // 0.15s - UI quick feedback
        static let short: UInt64 = 200_000_000     // 0.2s  - lightweight fetch
        static let medium: UInt64 = 300_000_000    // 0.3s  - standard detail
        static let long: UInt64 = 400_000_000      // 0.4s  - list or search
        static let veryLong: UInt64 = 500_000_000  // 0.5s  - heavy or multi-fetch
    }

    // MARK: - Paging
    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        try await Task.sleep(nanoseconds: Delay.veryLong)

        let allMovies = SharedPreviewMovies.moviesList
        let pageSize = 3
        let safePage = max(1, page)
        let startIndex = (safePage - 1) * pageSize

        let pageResults: [Movie]
        if startIndex < allMovies.count {
            let endIndex = min(startIndex + pageSize, allMovies.count)
            pageResults = Array(allMovies[startIndex..<endIndex])
        } else {
            pageResults = []
        }

        let totalPages = max(1, Int(ceil(Double(allMovies.count) / Double(pageSize))))

        return MovieResult(
            page: safePage,
            results: pageResults,
            totalPages: totalPages,
            totalResults: allMovies.count
        )
    }

    // MARK: - Movies
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await Task.sleep(nanoseconds: Delay.long)
        return MovieDetailPreviewData.starWarsDetail
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await Task.sleep(nanoseconds: Delay.medium)
        return MovieCreditsPreviewData.starWarsCredits()
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        try await Task.sleep(nanoseconds: Delay.medium)
        return PreviewData.sampleVideos
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        try await Task.sleep(nanoseconds: Delay.medium)
        return SharedPreviewMovies.moviesList
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderAvailability {
        try await Task.sleep(nanoseconds: Delay.short)
        return WatchProviderAvailability(
            requestedRegionCode: "SE",
            fallbackRegionCode: "US",
            resolvedRegionCode: "SE",
            source: .requestedRegion,
            region: PreviewData.mockWatchProviderRegion
        )
    }

    // MARK: - Person
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        try await Task.sleep(nanoseconds: Delay.medium)
        return PersonPreviewData.markHamill
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        try await Task.sleep(nanoseconds: Delay.medium)
        return PersonPreviewData.movieCredits
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        try await Task.sleep(nanoseconds: Delay.short)
        return PersonLinksPreviewData.markHamill
    }

    // MARK: - Discover
    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        try await Task.sleep(nanoseconds: Delay.long)

        if filters.contains(
            where: { $0.name == DiscoverQueryKey.withGenres && $0.value == "27" }
        ) {
            return DiscoverHorrorPreviewData.horrorMovies
        }
        return SharedPreviewMovies.moviesList
    }

    // MARK: - Misc
    func fetchNowPlayingMovies() async throws -> [Movie] {
        try await Task.sleep(nanoseconds: Delay.long)
        return SharedPreviewMovies.moviesList.reversed()
    }

    func fetchGenres() async throws -> [Genre] {
        try await Task.sleep(nanoseconds: Delay.short)
        return GenrePreviewData.genres
    }
}
