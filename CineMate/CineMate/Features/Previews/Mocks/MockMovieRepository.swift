//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

/// Local repository for the portfolio demo and SwiftUI previews.
/// Responses are deterministic, cancellation-aware and backed by `DemoCatalog`.
final class DemoMovieRepository: MovieProtocol {

    private let pageSize = 4

    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        try await prepareResponse()

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let movies = normalizedQuery.isEmpty
            ? DemoCatalog.moviesList
            : DemoCatalog.moviesList.filter {
                $0.title.localizedCaseInsensitiveContains(normalizedQuery)
            }
        return pagedResult(from: movies, page: page)
    }

    // MARK: - Movies

    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        try await prepareResponse()
        return pagedResult(from: DemoCatalog.movies(for: category), page: page)
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await prepareResponse()
        guard let detail = DemoCatalog.detail(for: movieId) else {
            throw DemoRepositoryError.movieNotFound(movieId)
        }
        return detail
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await prepareResponse()
        guard let credits = DemoCatalog.credits(for: movieId) else {
            throw DemoRepositoryError.movieNotFound(movieId)
        }
        return credits
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        try await prepareResponse()
        guard DemoCatalog.movie(withID: movieId) != nil else {
            throw DemoRepositoryError.movieNotFound(movieId)
        }
        return DemoCatalog.videos(for: movieId)
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        try await prepareResponse()
        guard DemoCatalog.movie(withID: movieId) != nil else {
            throw DemoRepositoryError.movieNotFound(movieId)
        }
        return DemoCatalog.recommendations(for: movieId)
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderAvailability {
        try await prepareResponse()
        guard let providers = DemoCatalog.watchProviders(for: movieId) else {
            throw DemoRepositoryError.movieNotFound(movieId)
        }
        return providers
    }

    // MARK: - People

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        try await prepareResponse()
        guard let detail = DemoCatalog.personDetail(for: personId) else {
            throw DemoRepositoryError.personNotFound(personId)
        }
        return detail
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        try await prepareResponse()
        guard let credits = DemoCatalog.movieCredits(for: personId) else {
            throw DemoRepositoryError.personNotFound(personId)
        }
        return credits
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        try await prepareResponse()
        guard let externalIDs = DemoCatalog.personExternalIDs(for: personId) else {
            throw DemoRepositoryError.personNotFound(personId)
        }
        return externalIDs
    }

    // MARK: - Discover

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        try await prepareResponse()

        var movies = DemoCatalog.moviesList
        let values = Dictionary(
            filters.compactMap { item in item.value.map { (item.name, $0) } },
            uniquingKeysWith: { _, latest in latest }
        )

        if let genreValue = values[DiscoverQueryKey.withGenres] {
            let requestedGenreIDs = Set(
                genreValue.split(separator: ",").compactMap { Int($0) }
            )
            if !requestedGenreIDs.isEmpty {
                movies = movies.filter { movie in
                    guard let detail = DemoCatalog.detail(for: movie.id) else { return false }
                    let movieGenreIDs = Set(detail.genres.map(\.id))
                    return requestedGenreIDs.isSubset(of: movieGenreIDs)
                }
            }
        }

        if let minimumValue = values[DiscoverQueryKey.minVoteAverage],
           let minimum = Double(minimumValue) {
            movies = movies.filter { ($0.voteAverage ?? 0) >= minimum }
        }

        movies = sorted(movies, by: values[DiscoverQueryKey.sortBy])
        let page = values[DiscoverQueryKey.page].flatMap(Int.init) ?? 1
        return pageSlice(from: movies, page: page)
    }

    // MARK: - Additional Endpoints

    func fetchNowPlayingMovies(page: Int, region: String?) async throws -> MovieResult {
        try await prepareResponse()
        return pagedResult(from: DemoCatalog.nowPlayingMovies, page: page)
    }

    func fetchGenres() async throws -> [Genre] {
        try await prepareResponse()
        return DemoCatalog.genres
    }

    // MARK: - Private Methods

    // Keeps demo calls cancellable without simulating network latency.
    private func prepareResponse() async throws {
        try Task.checkCancellation()
        await Task.yield()
        try Task.checkCancellation()
    }

    private func pagedResult(from movies: [Movie], page: Int) -> MovieResult {
        let safePage = max(1, page)
        let results = pageSlice(from: movies, page: safePage)
        let totalPages = movies.isEmpty ? 0 : (movies.count + pageSize - 1) / pageSize
        return MovieResult(
            page: safePage,
            results: results,
            totalPages: totalPages,
            totalResults: movies.count
        )
    }

    private func pageSlice(from movies: [Movie], page: Int) -> [Movie] {
        let safePage = max(1, page)
        let startIndex = (safePage - 1) * pageSize
        guard startIndex < movies.count else { return [] }
        let endIndex = min(startIndex + pageSize, movies.count)
        return Array(movies[startIndex..<endIndex])
    }

    private func sorted(_ movies: [Movie], by rawSortOption: String?) -> [Movie] {
        guard let rawSortOption, let option = SortOption(rawValue: rawSortOption) else {
            return movies
        }

        switch option {
        case .popularityDesc:
            return movies
        case .popularityAsc:
            return Array(movies.reversed())
        case .voteAverageDesc:
            return movies.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        case .voteAverageAsc:
            return movies.sorted { ($0.voteAverage ?? 0) < ($1.voteAverage ?? 0) }
        case .releaseDateDesc:
            return movies.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        case .releaseDateAsc:
            return movies.sorted { ($0.releaseDate ?? "") < ($1.releaseDate ?? "") }
        }
    }
}

/// Keeps existing preview call sites source-compatible.
typealias MockMovieRepository = DemoMovieRepository

private enum DemoRepositoryError: LocalizedError {
    case movieNotFound(Int)
    case personNotFound(Int)

    var errorDescription: String? {
        switch self {
        case .movieNotFound(let id):
            return "Movie \(id) is not part of the demo catalog."
        case .personNotFound(let id):
            return "Person \(id) is not part of the demo catalog."
        }
    }
}
