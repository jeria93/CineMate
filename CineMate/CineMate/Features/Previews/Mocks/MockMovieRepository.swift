//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

/// Mock repository for previews and tests.
/// Returns fixed data with short delays.
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
        return pagedResult(from: allMovies, page: page, pageSize: 6)
    }

    // MARK: - Mock Delay Configuration
    /// Small delays for preview and test flows.
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
        return pagedResult(from: SharedPreviewMovies.moviesList, page: page, pageSize: 3)
    }

    // MARK: - Movies
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await Task.sleep(nanoseconds: Delay.long)
        return MovieDetailPreviewData.starWarsDetail
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await Task.sleep(nanoseconds: Delay.medium)
        return MovieCreditsPreviewData.starWarsCredits(movieId: movieId)
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
    func fetchNowPlayingMovies(page: Int, region: String?) async throws -> MovieResult {
        try await Task.sleep(nanoseconds: Delay.long)
        return pagedResult(from: Array(SharedPreviewMovies.moviesList.reversed()), page: page, pageSize: 3)
    }

    func fetchGenres() async throws -> [Genre] {
        try await Task.sleep(nanoseconds: Delay.short)
        return GenrePreviewData.genres
    }

    private func pagedResult(from movies: [Movie], page: Int, pageSize: Int) -> MovieResult {
        let safePageSize = max(1, pageSize)
        let safePage = max(1, page)
        let startIndex = (safePage - 1) * safePageSize
        let endIndex = min(startIndex + safePageSize, movies.count)
        let pageResults = startIndex < movies.count ? Array(movies[startIndex..<endIndex]) : []
        let totalPages = max(1, (movies.count + safePageSize - 1) / safePageSize)

        return MovieResult(
            page: safePage,
            results: pageResults,
            totalPages: totalPages,
            totalResults: movies.count
        )
    }
}
