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
    @Published var selectedCategory: MovieCategory = .popular
    @Published var watchProviderRegion: WatchProviderRegion?
    @Published var favoriteMovies: Set<Int> = []
    @Published var isLoadingDetail: Bool = false
    private var listCache: [MovieCategory: [Movie]] = [:]

    var repository: MovieProtocol

    init(repository: MovieProtocol) {
        self.repository = repository
        print("[MovieVM] ▶️ init")
    }

    // MARK: - Favorites

    /// Toggles a movie in the favorites set.
    func toggleFavorite(for movie: Movie) {
        print("[MovieVM] toggleFavorite(id: \(movie.id))")
        if favoriteMovies.contains(movie.id) {
            favoriteMovies.remove(movie.id)
            print("[MovieVM] removed from favorites: \(movie.id)")
        } else {
            favoriteMovies.insert(movie.id)
            print("[MovieVM] added to favorites: \(movie.id)")
        }
    }

    /// Returns whether a movie is marked as favorite.
    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains(movie.id)
    }

    // MARK: - Loaders

    /// Loads detailed information for a given movie.
    func loadMovieDetails(for movieId: Int) async {
        print("[MovieVM] ▶️ loadMovieDetails(id: \(movieId))")
        isLoadingDetail = true
        defer {
            isLoadingDetail = false
            print("[MovieVM] ◀️ loadMovieDetails complete")
        }
        await load({
            try await repository.fetchMovieDetails(for: movieId)
        }, assignTo: \.movieDetail)
    }

    /// Loads credits for a given movie.
    func loadMovieCredits(for movieId: Int) async {
        print("[MovieVM] ▶️ loadMovieCredits(id: \(movieId))")
        await load({
            try await repository.fetchMovieCredits(for: movieId)
        }, assignTo: \.movieCredits)
        print("[MovieVM] ◀️ loadMovieCredits complete")
    }

    /// Loads videos for a given movie.
    func loadMovieVideos(for movieId: Int) async {
        print("[MovieVM] ▶️ loadMovieVideos(id: \(movieId))")
        await load({
            try await repository.fetchMovieVideos(for: movieId)
        }, assignTo: \.movieVideos)
        print("[MovieVM] ◀️ loadMovieVideos complete")
    }

    /// Fetches recommended movies for a given movie.
    func fetchRecommendedMovies(for movieId: Int) async {
        print("[MovieVM] ▶️ fetchRecommendedMovies(id: \(movieId))")
        await load({
            try await repository.fetchRecommendedMovies(for: movieId)
        }, assignTo: \.recommendedMovies)
        print("[MovieVM] ◀️ fetchRecommendedMovies complete")
    }

    /// Loads watch provider information for a given movie.
    func loadWatchProviders(for movieId: Int) async {
        print("[MovieVM] ▶️ loadWatchProviders(id: \(movieId))")
        await load({
            try await repository.fetchWatchProviders(for: movieId)
        }, assignTo: \.watchProviderRegion)
        print("[MovieVM] ◀️ loadWatchProviders complete")
    }

    // MARK: - Movie List (filter-based)

    /// Fetches popular movies list.
    func fetchPopularMovies() async {
        print("[MovieVM] ▶️ fetchPopularMovies")
        await fetch { try await repository.fetchPopularMovies() }
        print("[MovieVM] ◀️ fetchPopularMovies complete")
    }

    /// Fetches top-rated movies list.
    func fetchTopRatedMovies() async {
        print("[MovieVM] ▶️ fetchTopRatedMovies")
        await fetch { try await repository.fetchTopRatedMovies() }
        print("[MovieVM] ◀️ fetchTopRatedMovies complete")
    }

    /// Fetches upcoming movies list.
    func fetchUpComingMovies() async {
        print("[MovieVM] ▶️ fetchUpComingMovies")
        await fetch { try await repository.fetchUpcomingMovies() }
        print("[MovieVM] ◀️ fetchUpComingMovies complete")
    }

    /// Fetches trending movies list.
    func fetchTrendingMovies() async {
        print("[MovieVM] ▶️ fetchTrendingMovies")
        await fetch { try await repository.fetchTrendingMovies() }
        print("[MovieVM] ◀️ fetchTrendingMovies complete")
    }

    /// Loads movies based on the selected category, using cache if available.
    func loadMovies() async {
        print("[MovieVM] ▶️ loadMovies(category: \(selectedCategory))")
        if let cached = listCache[selectedCategory] {
            movies = cached
            print("[MovieVM] ◀️ loadMovies from cache (\(cached.count) items)")
            return
        }

        movies = []
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
        print("[MovieVM] ◀️ loadMovies complete (\(movies.count) items)")
    }

    /// Handles fetching movies and updates the view model's state.
    /// - Parameter fetcher: Closure that fetches a list of movies.
    private func fetch(_ fetcher: () async throws -> [Movie]) async {
        print("[MovieVM] ▶️ fetch(category: \(selectedCategory))")
        isLoading = true
        defer {
            isLoading = false
            print("[MovieVM] ◀️ fetch complete (isLoading=false)")
        }

        do {
            let fetched = try await fetcher()
            movies = fetched
            listCache[selectedCategory] = fetched
            errorMessage = nil
            print("[MovieVM] ✅ fetched \(fetched.count) movies for \(selectedCategory)")
        } catch {
            errorMessage = error.localizedDescription
            print("[MovieVM] ❌ fetch error: \(error.localizedDescription)")
        }
    }

    /// Loads any type of data asynchronously and assigns it to a specific @Published property.
    /// - Parameters:
    ///   - fetcher: An async closure returning a value of type T.
    ///   - keyPath: Writable keyPath to assign the result.
    private func load<T>(_ fetcher: () async throws -> T, assignTo keyPath: ReferenceWritableKeyPath<MovieViewModel, T?>) async {
        print("[MovieVM] ▶️ load(assignTo: \(keyPath))")
        do {
            let result = try await fetcher()
            self[keyPath: keyPath] = result
            print("[MovieVM] ✅ load successful assignTo: \(keyPath)")
        } catch {
            print("[MovieVM] ❌ load error for \(keyPath): \(error.localizedDescription)")
            self[keyPath: keyPath] = nil
        }
    }
}
