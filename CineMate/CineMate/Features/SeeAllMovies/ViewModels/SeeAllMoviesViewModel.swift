//
//  SeeAllMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

/// **SeeAllMoviesViewModel**
///
/// Manages fetching, caching and pagination of movie lists for the "See All Movies" screen.
///
/// ### Responsibilities
/// - Fetch paginated movie lists from the repository
/// - Cache each page per filter to avoid redundant network calls
/// - Protect against duplicate concurrent fetches (in-flight guard)
/// - Track loading and error states for UI feedback
/// - Append only new, unique movies to the list
///
/// ### Usage
/// ```swift
/// @StateObject var vm = SeeAllMoviesViewModel(
///     repository: MovieRepository(),
///     filter: DiscoverFilter(sortOption: .popularityDesc)
/// )
///
/// // On appear or refresh
/// Task { await vm.loadInitialMovies() }
///
/// // In grid row .onAppear
/// Task { await vm.loadNextPageIfNeeded(currentItem: movie) }
/// ```
@MainActor
final class SeeAllMoviesViewModel: ObservableObject {
    // MARK: - Published State

    /// The movies to display in the grid.
    @Published var movies: [Movie] = []

    /// Indicates an ongoing fetch for UI spinners.
    @Published var isLoading = false

    /// Holds an error message when a fetch fails.
    @Published var errorMessage: String?

    /// Computed flag for whether an error exists.
    var hasError: Bool { errorMessage != nil }

    // MARK: - Dependencies

    /// Source of truth for network/data operations.
    private let repository: MovieProtocol

    /// The filter criteria used for the discover endpoint.
    private let filter: DiscoverFilter

    // MARK: - Pagination & Cache

    /// Encapsulates page tracking and prevents duplicate page requests.
    let pagination = PaginationManager()

    /// In-memory cache: filter → (pageIndex → movie list).
    private var movieCache: [DiscoverFilter: [Int: [Movie]]] = [:]

    /// Tracks already-appended IDs to avoid duplicates.
    private var loadedMovieIDs = Set<Int>()

    // MARK: - In-flight Guard

    /// Holds the current fetch task for cancellation.
    private var fetchTask: Task<Void, Never>?

    // MARK: - Initialization

    /// - Parameters:
    ///   - repository: Provides movie data.
    ///   - filter: Defines discover query parameters.
    init(repository: MovieProtocol, filter: DiscoverFilter) {
        self.repository = repository
        self.filter = filter
    }

    // MARK: - Public API

    /// Load the very first page if none loaded yet.
    func loadInitialMovies() async {

        /// To skip real network calls or tunga initialiseringar.
        guard !ProcessInfo.processInfo.isPreview else { return }

        guard movies.isEmpty else { return }
        clearCache()
        await fetchNextPage()
    }

    /// Fetch the next page, with cache look-up and in-flight protection.
    func fetchNextPage() async {

        /// To skip real network calls or tunga initialiseringar.
        guard !ProcessInfo.processInfo.isPreview else { return }

        // Cancel any ongoing fetch to prevent races
        fetchTask?.cancel()
        errorMessage = nil

        // Determine which page index to fetch
        let key = currentFilterKey
        let isFirstLoad = movies.isEmpty && pagination.state.currentPage == 1
        let pageToFetch = isFirstLoad
        ? 1
        : pagination.state.currentPage + 1

        // Serve from cache if available
        if let cached = movieCache[key]?[pageToFetch] {
            appendUniqueMovies(cached)
            pagination.finishFetching(
                page: pageToFetch,
                totalPages: pagination.state.totalPages
            )
            return
        }

        // Prevent duplicate fetch calls for pages > 1
        if !isFirstLoad {
            guard pagination.startFetchingNextPage() else { return }
        }

        // Begin async fetch
        fetchTask = Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // Build query with correct page
                let filterForPage = filter.withPage(pageToFetch)
                let newMovies = try await repository.discoverMovies(
                    filters: filterForPage.queryItems
                )

                // Cache this page’s results
                movieCache[key, default: [:]][pageToFetch] = newMovies

                // Append unique movies to list
                appendUniqueMovies(newMovies)

                // Compute total pages based on real page size
                let pageSize = 3
                let totalPages = max(
                    1,
                    Int(ceil(Double(movies.count) / Double(pageSize)))
                )

                // Update pagination state
                pagination.finishFetching(
                    page: pageToFetch,
                    totalPages: totalPages
                )
            } catch {
                // On error (unless cancelled), record and reset fetch flag
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    pagination.finishFetching(
                        page: pagination.state.currentPage,
                        totalPages: pagination.state.totalPages
                    )
                }
            }
        }

        // Wait for completion
        await fetchTask?.value
    }

    /// Trigger loading of next page when the user scrolls to the last item.
    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard
            let last = movies.last,
            last.id == currentItem.id,
            pagination.hasMorePages
        else { return }
        await fetchNextPage()
    }

    /// Reset all cache, IDs and pagination to start fresh.
    func clearCache() {
        movies.removeAll()
        loadedMovieIDs.removeAll()
        pagination.reset()
        errorMessage = nil
    }

    // MARK: - Private Helpers

    /// Filter key ignoring page to group cached pages by criteria.
    private var currentFilterKey: DiscoverFilter {
        var updated = filter
        updated.page = 0
        return updated
    }

    /// Append only movies whose IDs haven’t been seen yet.
    private func appendUniqueMovies(_ newMovies: [Movie]) {
        for movie in newMovies where !loadedMovieIDs.contains(movie.id) {
            movies.append(movie)
            loadedMovieIDs.insert(movie.id)
        }
    }
}

// MARK: - DiscoverFilter extension

private extension DiscoverFilter {
    /// Return a copy with the specified page number set.
    func withPage(_ page: Int) -> DiscoverFilter {
        var updated = self
        updated.page = page
        return updated
    }
}
