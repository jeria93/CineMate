//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

final class MockMovieRepository: MovieProtocol {
    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        print("Upcoming")
        fatalError()
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
