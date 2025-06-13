//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

final class MockMovieRepository: MovieProtocol {
    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        PreviewData.sampleVideos
    }
    
    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        PreviewData.starWarsCredits
    }
    
    
    func fetchPopularMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchTrendingMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchTopRatedMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchUpcomingMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }


}
