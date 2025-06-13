//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

@MainActor
class MovieViewModel: ObservableObject {

    @Published var movies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var movieCredits: MovieCredits?
    @Published var movieVideos: [MovieVideo]?
    @Published var selectedCategory: MovieCategory = .popular {
        didSet {
            Task { await loadMovies() }
        }
    }

    @Published var favoriteMovies: Set<Int> = []

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

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    func loadMovieVideos(for movieId: Int) async {
        do {
            let videos = try await repository.fetchMovieVideos(for: movieId)
            self.movieVideos = videos
        } catch {
            print("Error fetching videos: \(error.localizedDescription)")
            self.movieVideos = nil
        }
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await repository.fetchMovieCredits(for: movieId)
    }

    func loadMovieCredits(for movieId: Int) async {
        do {
            let credits = try await repository.fetchMovieCredits(for: movieId)
            self.movieCredits = credits
        } catch {
            print("Error fetching credits: \(error.localizedDescription)")
            self.movieCredits = nil
        }
    }

    func fetchPopularMovies() async {
        await fetch { try await repository.fetchPopularMovies() }
    }

    func fetchTopRatedMovies() async {
        await fetch { try await repository.fetchTopRatedMovies() }
    }

    func fetchUpComingMovies() async {
        await fetch { try await repository.fetchUpcomingMovies() }
    }

    func fetchTrendingMovies() async {
        await fetch { try await repository.fetchTrendingMovies() }
    }

    func loadMovies() async {
        switch selectedCategory {
        case .popular:
            await fetchPopularMovies()
        case .topRated:
            await fetchTopRatedMovies()
        case .upcoming:
            await fetchUpComingMovies()
        case .trending:
            await fetchTrendingMovies()
        }
    }

    /// Handles fetching movies and updates the view model's state.
    /// - Parameter fetcher: Closure that fetches a list of movies.
    private func fetch(_ fetcher: () async throws -> [Movie]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await fetcher()
            movies = result
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
