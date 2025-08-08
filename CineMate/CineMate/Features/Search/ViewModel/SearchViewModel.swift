//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// A ViewModel that powers the Search screen in CineMate.
///
/// Handles debounced user input, validation, pagination, caching,
/// and in-flight protection to optimize API usage and user experience.
///
/// This ViewModel is designed for SwiftUI with async/await and supports:
/// - Previews with mock data
/// - Memory efficiency through result caching
/// - Pagination and duplicate request protection
/// - Validation and debouncing of input
/// - Custom loading and error states
///
/// Preview behavior:
/// - Skips debounce and validation logic in Xcode Previews (`isPreview`)
/// - Injects mock results during preview search for realistic UI rendering
///
///
/// Responsibilities:
/// - Debounce user input before triggering searches
/// - Validate queries before making requests
/// - Fetch search results from a repository
/// - Cache results to reduce unnecessary API calls
/// - Prevent duplicate network calls (in-flight protection)
/// - Manage pagination and loading states
/// - Provide user-facing errors and validation feedback
///
/// Usage:
/// ```swift
/// @StateObject var viewModel = SearchViewModel()
/// SearchView(viewModel: viewModel)
/// ```
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published Properties (Observed by SwiftUI)

    /// The user's raw query from the search bar.
    @Published var query: String = "" {
        didSet { debounceSearch() }
    }

    /// The current list of search results.
    @Published var results: [Movie] = []

    /// Whether a network request is in progress.
    @Published var isLoading = false

    /// The latest error shown to the user (e.g. network error, no results).
    @Published var error: SearchError?

    /// The latest validation message if the query is invalid.
    @Published var validationMessage: String?

    /// The last query that passed validation and triggered a real search.
    @Published var lastValidQuery: String?

    /// The current query after trimming whitespace.
    @Published var trimmedQuery: String = ""

    // MARK: - Dependencies

    /// The injected repository for fetching movies.
    internal let repository: MovieProtocol

    /// Task used to debounce typing input.
    private var debounceTask: Task<Void, Never>?

    // MARK: - Cache & In-Flight Protection

    /// Stores previously fetched results to avoid repeated API calls.
    private var cache: [String: [Movie]] = [:]

    /// Keeps track of queries currently being fetched to avoid duplicate requests.
    private var inFlight: Set<String> = []

    /// Limits the number of cached queries to avoid memory bloat.
    private let maxCacheSize = 20

    // MARK: - Pagination

    /// Tracks the current page and pagination state.
    private var pagination = PaginationManager()

    // MARK: - Init

    /// Creates a new instance of the SearchViewModel.
    /// - Parameter repository: A repository conforming to `MovieProtocol`.
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Triggers a new search from outside the ViewModel (e.g. retry button).
    /// - Parameter query: The string to search for.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }

        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    /// Called during infinite scroll when a movie row appears near the bottom.
    /// - Parameter currentItem: The currently visible movie.
    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard let currentItem = currentItem else { return }

        let thresholdIndex = results.index(results.endIndex, offsetBy: -5, limitedBy: results.startIndex) ?? results.startIndex
        if results.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await fetchNextPage()
        }
    }
}

// MARK: - Private Helpers

private extension SearchViewModel {

    /// Debounces user input by 0.4 seconds to avoid spamming the API.
    func debounceSearch() {

        guard !ProcessInfo.processInfo.isPreview else { return }

        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            await self?.handleQuery()
        }
    }

    /// Validates and cleans the user input before triggering a search.
    func handleQuery() async {

        guard !ProcessInfo.processInfo.isPreview else { return }

        let result = SearchValidator.validate(query)
        trimmedQuery = result.trimmed ?? ""
        validationMessage = result.message

        guard let trimmed = result.trimmed, result.isValid else {
            resetSearchState()
            return
        }

        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    /// Executes the actual search:
    /// - Checks if data already exists in cache.
    /// - Prevents duplicate in-flight requests.
    /// - Calls the repository for page 1 results.
    /// - Updates UI state accordingly.
    func executeSearch(for trimmed: String) async {
        // Provide mock data during preview mode
        if ProcessInfo.processInfo.isPreview {
            results = SharedPreviewMovies.moviesList
            error = nil
            return
        }

        pagination.reset()

        // Use cached result if available
        if let cached = cache[trimmed] {
            results = cached
            error = cached.isEmpty ? .noResults : nil
            return
        }

        // Avoid duplicate requests
        guard !inFlight.contains(trimmed) else { return }
        inFlight.insert(trimmed)

        setLoading(true)
        do {
            let response = try await repository.searchMovies(query: trimmed, page: 1)

            results = response.results
            error = response.results.isEmpty ? .noResults : nil
            cache[trimmed] = response.results
            trimCacheIfNeeded()

            pagination.finishFetching(page: 1, totalPages: response.totalPages)
        } catch {
            results = []
            self.error = .networkFailure
        }

        inFlight.remove(trimmed)
        setLoading(false)
    }

    /// Fetches the next page of results if available.
    func fetchNextPage() async {
        guard pagination.startFetchingNextPage(),
              let query = lastValidQuery else { return }

        do {
            let nextPage = pagination.state.currentPage + 1
            let response = try await repository.searchMovies(query: query, page: nextPage)

            results.append(contentsOf: response.results)
            pagination.finishFetching(page: nextPage, totalPages: response.totalPages)
        } catch {
            pagination.cancelFetching()
            self.error = .networkFailure
        }
    }

    /// Updates the loading state and clears errors when loading begins.
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading { error = nil }
    }

    /// Resets the UI state if the query is invalid.
    func resetSearchState() {
        results = []
        error = nil
        isLoading = false
    }

    /// Removes oldest entries from cache if the limit is exceeded.
    func trimCacheIfNeeded() {
        if cache.count > maxCacheSize {
            let excess = cache.count - maxCacheSize
            let keysToRemove = cache.keys.prefix(excess)
            for key in keysToRemove {
                cache.removeValue(forKey: key)
            }
        }
    }
}
