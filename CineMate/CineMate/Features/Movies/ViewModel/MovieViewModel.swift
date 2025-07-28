//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation
import SwiftUI

@MainActor
final class MovieViewModel: ObservableObject {
    // MARK: - Published state
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var movieCredits: MovieCredits?
    @Published var movieVideos: [MovieVideo]?
    @Published var recommendedMovies: [Movie]?
    @Published var movieDetail: MovieDetail?
    @Published var watchProviderRegion: WatchProviderRegion?

    @Published var selectedCategory: MovieCategory = .popular {
        didSet { Task { await loadMovies() } }
    }
    @Published var favoriteMovies: Set<Int> = []
    @Published var isLoadingDetail = false

    // MARK: - Dependencies
    internal let repository: MovieProtocol

    // MARK: - In-memory cache & in-flight guard
    private var listCache: [MovieCategory: [Movie]] = [:]
    private var fetchListTask: Task<Void, Never>?

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Favorites

    func toggleFavorite(for movie: Movie) {
        if favoriteMovies.contains(movie.id) {
            favoriteMovies.remove(movie.id)
        } else {
            favoriteMovies.insert(movie.id)
        }
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains(movie.id)
    }

    // MARK: - Movie List

    /// Loads the list of movies for the selected category,
    /// using an in-memory cache and guarding against duplicate in-flight calls.
    func loadMovies() async {
        // 1) Return cached
        if let cached = listCache[selectedCategory] {
            movies = cached
            return
        }
        // 2) If a fetch is already in flight, await its completion
        if let task = fetchListTask {
            await task.value
            return
        }
        // 3) Start a new fetch task
        fetchListTask = Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let fetched: [Movie]
                switch selectedCategory {
                case .popular:
                    fetched = try await repository.fetchPopularMovies()
                case .topRated:
                    fetched = try await repository.fetchTopRatedMovies()
                case .trending:
                    fetched = try await repository.fetchTrendingMovies()
                case .upcoming:
                    fetched = try await repository.fetchUpcomingMovies()
                }
                movies = fetched
                listCache[selectedCategory] = fetched
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        // 4) Wait for the fetch to finish
        await fetchListTask?.value
        fetchListTask = nil
    }

    // MARK: - Movie Detail

    /// Loads detailed info for a movie (credits, videos, recommendations, detail, providers).
    func loadMovieDetails(for movieId: Int) async {
        isLoadingDetail = true
        defer { isLoadingDetail = false }

        async let details     = repository.fetchMovieDetails(for: movieId)
        async let credits     = repository.fetchMovieCredits(for: movieId)
        async let videos      = repository.fetchMovieVideos(for: movieId)
        async let recommended = repository.fetchRecommendedMovies(for: movieId)
        async let providers   = repository.fetchWatchProviders(for: movieId)

        do {
            movieDetail         = try await details
            movieCredits        = try await credits
            movieVideos         = try await videos
            recommendedMovies   = try await recommended
            watchProviderRegion = try await providers
        } catch {
            print("MovieViewModel loadMovieDetails error:", error)
        }
    }
}
