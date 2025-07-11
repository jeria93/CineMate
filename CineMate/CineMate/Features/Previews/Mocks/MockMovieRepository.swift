//
//  MockMovieRepository.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

final class MockMovieRepository: MovieProtocol {

    func fetchPopularMovies() async throws -> [Movie] {
        PreviewData.moviesList.shuffled()
    }

    func fetchTrendingMovies() async throws -> [Movie] {
        [PreviewData.inception, PreviewData.starWars]
    }

    func fetchTopRatedMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchUpcomingMovies() async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchNowPlayingMovies() async throws -> [Movie] {
        PreviewData.moviesList.reversed()
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        PreviewData.starWarsCredits
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        PreviewData.sampleVideos
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        PreviewData.moviesList
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        PreviewData.starWarsDetail
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        PreviewData.markHamillPersonDetail
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        PreviewData.markHamillMovieCredits
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        .preview
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderRegion {
        PreviewData.mockWatchProviderRegion
    }

    func searchMovies(query: String) async throws -> [Movie] {
        PreviewData.moviesList.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        PreviewData.moviesList
    }
}
