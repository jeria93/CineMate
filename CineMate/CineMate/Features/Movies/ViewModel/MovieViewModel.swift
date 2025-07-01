//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

@MainActor
final class MovieViewModel: ObservableObject {
    
    @Published var movies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var movieCredits: MovieCredits?
    @Published var movieVideos: [MovieVideo]?
    @Published var recommendedMovies: [Movie]?
    @Published var movieDetail: MovieDetail?
    @Published var selectedCategory: MovieCategory = .popular {
        didSet {
            Task { await loadMovies() }
        }
    }
    @Published var watchProviders: [WatchProvider]?
    @Published var favoriteMovies: Set<Int> = []
    
    var repository: MovieProtocol
    
    init(repository: MovieProtocol) {
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
    
    // MARK: - Loaders
    
    
    func loadMovieDetails(for movieId: Int) async {
        await load({
            try await repository.fetchMovieDetails(for: movieId)
        }, assignTo: \.movieDetail)
    }
    
    func loadMovieCredits(for movieId: Int) async {
        await load({
            try await repository.fetchMovieCredits(for: movieId)
        }, assignTo: \.movieCredits)
    }
    
    //    Remove?
    func loadMovieVideos(for movieId: Int) async {
        await load({
            try await repository.fetchMovieVideos(for: movieId)
        }, assignTo: \.movieVideos)
    }
    
    func fetchRecommendedMovies(for movieId: Int) async {
        await load({
            try await repository.fetchRecommendedMovies(for: movieId)
        }, assignTo: \.recommendedMovies)
    }

    func loadWatchProviders(for movieId: Int) async {
        await load({
            try await repository.fetchWatchProviders(for: movieId)?.flatrate ?? []
        }, assignTo: \.watchProviders)
    }

    // MARK: - Movie List (filter-based)
    
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
    
    /// Loads any type of data asynchronously and assigns it to a specific @Published property using a keyPath.
    /// - Parameters:
    ///   - fetcher: An asynchronous function that returns a value of any type `T`.
    ///   - keyPath: A writable keyPath to the `@Published` property in `MovieViewModel` where the result should be stored.
    /// - Note: On error, the property is set to `nil` and the error is printed.
    private func load<T>(_ fetcher: () async throws -> T, assignTo keyPath: ReferenceWritableKeyPath<MovieViewModel, T?>) async {
        do {
            let result = try await fetcher()
            self[keyPath: keyPath] = result
        } catch {
            print("Error: \(error.localizedDescription)")
            self[keyPath: keyPath] = nil
        }
    }
    
}
