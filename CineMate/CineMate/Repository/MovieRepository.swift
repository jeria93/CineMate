//
//  MovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

final class MovieRepository: MovieProtocol {

    private let service: TMDBService

    init(service: TMDBService = TMDBService()) {
        self.service = service
    }
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await service.fetchMovieDetails(for: movieId)
    }

    func fetchPopularMovies() async throws -> [Movie] {
        try await service.fetchPopularMovies()
    }

    func fetchTrendingMovies() async throws -> [Movie] {
        try await service.fetchTrendingMovies()
    }

    func fetchTopRatedMovies() async throws -> [Movie] {
        try await service.fetchTopRatedMovies()
    }

    func fetchUpcomingMovies() async throws -> [Movie] {
        try await service.fetchUpcomingMovies()
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await service.fetchMovieCredits(for: movieId)
    }
    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        try await service.fetchMovieVideos(for: movieId)
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        try await service.fetchRecommendedMovies(for: movieId)
    }
}
// ide: skapa en extension om denna fil blir för lång, varje extension kan ha respektive endpoints, tex söka, hämta etc
