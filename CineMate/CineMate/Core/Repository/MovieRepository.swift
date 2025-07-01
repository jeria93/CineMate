//
//  MovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

final class MovieRepository: MovieProtocol {
    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion {
        let response = try await service.fetchWatchProviders(for: movieId)
        return response.results["SE"] ?? .empty
    }
    
    
    private let service: TMDBService
    
    init(service: TMDBService = TMDBService()) {
        self.service = service
    }
    
    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        try await service.fetchPersonExternalIDs(for: personId)
    }
    
    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        try await service.fetchPersonMovieCredits(for: personId)
    }
    
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        try await service.fetchPersonDetail(for: personId)
    }
    
    
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await service.fetchMovieDetails(for: movieId)
    }
    
    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        try await service.fetchRecommendedMovies(for: movieId)
    }
    
    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        try await service.fetchMovieVideos(for: movieId)
    }
    
    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await service.fetchMovieCredits(for: movieId)
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
    

}
