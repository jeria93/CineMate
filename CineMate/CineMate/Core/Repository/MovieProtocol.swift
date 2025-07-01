//
//  MovieProtocol.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

protocol MovieProtocol {
    func fetchPopularMovies() async throws -> [Movie]
    func fetchTrendingMovies() async throws -> [Movie]
    func fetchTopRatedMovies() async throws -> [Movie]
    func fetchUpcomingMovies() async throws -> [Movie]
    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits
    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo]
    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie]
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail
    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit]
    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs
    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion?
}
