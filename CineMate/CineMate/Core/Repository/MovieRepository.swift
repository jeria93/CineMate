//
//  MovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Concrete repository that interacts with `TMDBService` to fetch movies and related data.
/// Handles both single-page and paginated requests.
final class MovieRepository: MovieProtocol {

    private let service: TMDBService

    init(service: TMDBService = TMDBService()) {
        self.service = service
    }

    // MARK: - Paging
    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        switch category {
        case .popular:
            return try await service.fetchPopularMovies(page: page)
        case .topRated:
            return try await service.fetchTopRatedMovies(page: page)
        case .trending:
            return try await service.fetchTrendingMovies(page: page)
        case .upcoming:
            return try await service.fetchUpcomingMovies(page: page)
        }
    }

    // MARK: - Movies
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await service.fetchMovieDetails(for: movieId)
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await service.fetchMovieCredits(for: movieId)
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        try await service.fetchMovieVideos(for: movieId)
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        let result = try await service.fetchRecommendedMovies(for: movieId)
        return result.results
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion {
        try await service.fetchWatchProviderRegion(for: movieId)
    }

    // MARK: - Person
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        try await service.fetchPersonDetail(for: personId)
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        try await service.fetchPersonMovieCredits(for: personId)
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        try await service.fetchPersonExternalIDs(for: personId)
    }

    // MARK: - Search & Discover
    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        try await service.searchMovies(query: query, page: page)
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        try await service.discoverMovies(filters: filters)
    }

    // MARK: - Misc
    func fetchNowPlayingMovies() async throws -> [Movie] {
        try await service.fetchNowPlayingMovies()
    }

    func fetchGenres() async throws -> [Genre] {
        try await service.fetchGenres()
    }
}
