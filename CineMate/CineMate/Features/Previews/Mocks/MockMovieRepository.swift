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

        // Always return the same movies regardless of query or page
        let mockResults = SharedPreviewMovies.moviesList

        return MovieResult(
            page: page,
            results: mockResults,
            totalPages: 1,
            totalResults: mockResults.count
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
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allMovies.count)
        let pageResults = Array(allMovies[startIndex..<endIndex])

        return MovieResult(
            page: page,
            results: pageResults,
            totalPages: Int(ceil(Double(allMovies.count) / Double(pageSize))),
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

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion {
        try await Task.sleep(nanoseconds: Delay.short)
        return PreviewData.mockWatchProviderRegion
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

    // MARK: - Search & Discover
    func searchMovies(query: String) async throws -> [Movie] {
        try await Task.sleep(nanoseconds: Delay.long)
        return SharedPreviewMovies.moviesList.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        try await Task.sleep(nanoseconds: Delay.long)
        if filters.contains(where: { $0.name == "with_genres" && $0.value == "27" }) {
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
