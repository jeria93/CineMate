//
//  SeeAllMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

/// ViewModel responsible for fetching and caching paginated movie results
/// for the "See All Movies" screen.
///
/// Features:
/// - Caches pages per filter to reduce redundant network calls.
/// - Provides in-flight protection to avoid duplicate concurrent requests.
/// - Tracks loading, error, and movie states for state-driven UI.
@MainActor
final class SeeAllMoviesViewModel: ObservableObject {
    /// Current list of movies displayed in the view.
    @Published var movies: [Movie] = []

    /// Loading and error flags for state-driven UI.
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    /// Movie repository used to fetch movie data.
    private let repository: MovieProtocol

    /// Filter defining the type of movies to fetch.
    private let filter: DiscoverFilter

    // MARK: - Internal state

    /// Paging and caching
    private var currentPage = 1
    private var movieCache: [DiscoverFilter: [Int: [Movie]]] = [:]

    /// Used to avoid duplicates and concurrent fetches
    private var loadedMovieIDs = Set<Int>()
    private var fetchTask: Task<Void, Never>? = nil

    // MARK: - Initialization

    init(repository: MovieProtocol, filter: DiscoverFilter) {
        self.repository = repository
        self.filter = filter
    }

    // MARK: - Public API

    /// Loads the first page of movies if no movies are currently loaded.
    /// Uses cache if available.
    func loadInitialMovies() async {
        guard movies.isEmpty else { return }
        await fetchMoreMovies()
    }

    /// Loads the next page of movies.
    /// - Uses cached results if the page has already been fetched.
    /// - Avoids concurrent duplicate requests via in-flight protection.
    func fetchMoreMovies() async {
        let key = currentFilterKey

        // 1. Serve from cache if this page has been fetched before
        if let cached = movieCache[key]?[currentPage] {
            MovieLoaderHelper.appendNewMovies(
                currentMovies: &movies,
                newMovies: cached,
                seenIDs: &loadedMovieIDs
            )
            currentPage += 1
            return
        }

        // 2. In-flight protection: wait for the ongoing fetch to complete
        if let existingTask = fetchTask {
            await existingTask.value
            return
        }

        // 3. Start a new fetch task
        fetchTask = Task { await performFetch(for: key) }
        await fetchTask?.value
        fetchTask = nil
    }

    /// Clears all cached data and resets the state.
    /// Use this when the user changes filters or triggers a manual refresh.
    func clearCache() {
        movies.removeAll()
        loadedMovieIDs.removeAll()
        currentPage = 1
    }

    // MARK: - Private helpers

    /// Returns the cache key for the current filter, ignoring page number.
    private var currentFilterKey: DiscoverFilter {
        var updated = filter
        updated.page = 0
        return updated
    }

    /// Returns the filter including the current page number.
    private var currentFilter: DiscoverFilter {
        var updated = filter
        updated.page = currentPage
        return updated
    }

    /// Performs the network fetch and updates state, cache, and movies.
    private func performFetch(for key: DiscoverFilter) async {
        isLoading = true
        hasError = false

        do {
            let newMovies = try await repository.discoverMovies(filters: currentFilter.queryItems)
            print("[SeeAllMoviesViewModel] fetched \(newMovies.count) for page \(currentPage)")

            // Ensure cache dictionary exists for this filter
            if movieCache[key] == nil {
                movieCache[key] = [:]
            }
            movieCache[key]?[currentPage] = newMovies

            // Append new movies and avoid duplicates
            MovieLoaderHelper.appendNewMovies(
                currentMovies: &movies,
                newMovies: newMovies,
                seenIDs: &loadedMovieIDs
            )

            currentPage += 1
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            print("[SeeAllMoviesViewModel] fetch failed:", error)
        }

        isLoading = false
    }
}
