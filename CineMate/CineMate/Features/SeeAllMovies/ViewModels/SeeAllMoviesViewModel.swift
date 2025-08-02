//
//  SeeAllMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

@MainActor
final class SeeAllMoviesViewModel: ObservableObject {
    // MARK: - Published state
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let repository: MovieProtocol
    private let filter: DiscoverFilter

    // MARK: - Internal state
    private var currentPage = 1
    private var loadedMovieIDs = Set<Int>()
    private var fetchTask: Task<Void, Never>? = nil

    // Cache per filter → per sida
    private var movieCache: [DiscoverFilter: [Int: [Movie]]] = [:]

    init(repository: MovieProtocol, filter: DiscoverFilter) {
        self.repository = repository
        self.filter = filter
    }

    // MARK: - Public API

    /// Loads the first page if empty
    func loadInitialMovies() async {
        guard movies.isEmpty else { return }
        await fetchMoreMovies()
    }

    /// Loads the next page of movies, using cache if available
    func fetchMoreMovies() async {
        let key = currentFilterKey

        // 1️⃣ Use cached page if available
        if let cached = movieCache[key]?[currentPage] {
            MovieLoaderHelper.appendNewMovies(
                currentMovies: &movies,
                newMovies: cached,
                seenIDs: &loadedMovieIDs
            )
            currentPage += 1
            return
        }

        // 2️⃣ In-flight protection
        if let existingTask = fetchTask {
            await existingTask.value
            return
        }

        // 3️⃣ Start a new fetch
        fetchTask = Task { await performFetch(for: key) }
        await fetchTask?.value
        fetchTask = nil
    }

    /// Clears all cache and resets state (useful if user changes filter)
    func clearCache() {
        movies.removeAll()
        loadedMovieIDs.removeAll()
        currentPage = 1
    }

    // MARK: - Private

    /// Key used for caching (ignore page)
    private var currentFilterKey: DiscoverFilter {
        var updated = filter
        updated.page = 0
        return updated
    }

    /// Fetches from repository and updates cache + state
    private func performFetch(for key: DiscoverFilter) async {
        isLoading = true
        hasError = false

        do {
            let newMovies = try await repository
                .discoverMovies(filters: currentFilter.queryItems)

            // Ensure cache dictionary exists
            if movieCache[key] == nil {
                movieCache[key] = [:]
            }

            // Cache this page
            movieCache[key]?[currentPage] = newMovies

            // Append to movies (avoid duplicates)
            MovieLoaderHelper.appendNewMovies(
                currentMovies: &movies,
                newMovies: newMovies,
                seenIDs: &loadedMovieIDs
            )

            currentPage += 1
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Filter including current page
    private var currentFilter: DiscoverFilter {
        var updated = filter
        updated.page = currentPage
        return updated
    }
}
