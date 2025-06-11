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
}
