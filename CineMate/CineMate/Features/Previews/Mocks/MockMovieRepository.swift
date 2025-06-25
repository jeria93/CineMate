//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

final class MockMovieRepository: MovieProtocol {

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        PreviewData.markHamillMovieCredits
    }

    
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        PreviewData.markHamillPersonDetail
    }
    
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        PreviewData.starWarsDetail
    }
    
    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        PreviewData.moviesList
    }
    
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
