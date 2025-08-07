//
//  MovieProtocol.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Protocol defining all movie, person, search, and discovery methods.
/// Implemented by `MovieRepository`.
protocol MovieProtocol {
    // MARK: - Paging
    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult

    // MARK: - Movies
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail
    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits
    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo]
    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie]
    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion

    // MARK: - Person / Search / Discover
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail
    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit]
    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs

    /// Updated: supports pagination
    func searchMovies(query: String, page: Int) async throws -> MovieResult
    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie]

    // MARK: - Misc
    func fetchNowPlayingMovies() async throws -> [Movie]
    func fetchGenres() async throws -> [Genre]
}
