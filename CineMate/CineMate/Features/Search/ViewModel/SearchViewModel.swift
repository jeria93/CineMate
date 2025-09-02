//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// # SearchViewModel
/// Drives the **Search** screen.
/// - Debounce on text changes
/// - Validate input
/// - Page & cache results
/// - Prevent duplicate requests
///
/// ## Previews
/// In Xcode Previews, network work is skipped and stable mock data is used.
///
/// ## Guest mode
/// Set `isAutoSearchEnabled = false` to turn off auto-search (e.g. for guest accounts).
/// Manual `search(_:)` still works when you decide to allow it.
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published (UI state exposed to the view)

    /// Raw text from the search bar. Debounced on change.
    @Published var query: String = "" { didSet { debounceSearch() } }

    /// Current results to render.
    @Published private(set) var results: [Movie] = []

    /// `true` while page 1 is loading.
    @Published private(set) var isLoading = false

    /// User-facing error (e.g. network failure, no results).
    @Published var error: SearchError?

    /// Validation feedback for `query` (e.g. invalid characters).
    @Published var validationMessage: String?

    /// Controls whether typing should auto-trigger searches.
    /// Set to `false` to disable auto-search (e.g. for guest users).
    @Published var isAutoSearchEnabled: Bool = true

    /// Last normalized query that triggered a real search.
    @Published private(set) var lastValidQuery: String?

    /// `query` trimmed of whitespace (kept for UI/logic).
    @Published private(set) var trimmedQuery: String = ""

    // MARK: - Dependencies

    /// Abstraction for fetching movies (real or mocked).
    let repository: MovieProtocol

    // MARK: - Runtime (internal)

    /// Debounce worker for keystrokes.
    private var debounceTask: Task<Void, Never>?

    /// Simple in-memory cache: `query → results`.
    private var cache: [String: [Movie]] = [:]

    /// Tracks queries currently being fetched to avoid duplicates.
    private var inFlight: Set<String> = []

    /// Max number of cached queries kept in memory.
    private let maxCacheSize = 20

    /// Manages current/total pages and fetch state.
    private var pagination = PaginationManager()

    // MARK: - Init

    /// Creates a new view model.
    /// - Parameter repository: Movie data source (defaults to production).
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Manually trigger a search (e.g. from a submit button or retry).
    /// - Parameter query: Raw user text.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }
        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    /// Ask for the next page when the given item gets close to the bottom.
    /// - Parameter currentItem: The row about to reach the end.
    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = results.index(results.endIndex, offsetBy: -5, limitedBy: results.startIndex) ?? results.startIndex
        if results.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await fetchNextPage()
        }
    }

    /// Debounce keystrokes so we don't spam the API.
    /// Skips entirely in Xcode Previews.
    func debounceSearch() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
            await self?.handleQuery()
        }
    }
}

// MARK: - Private helpers
private extension SearchViewModel {

    /// Validate and normalize the current `query`, then search if valid.
    /// Respects `isAutoSearchEnabled`.
    /// Skips entirely in Xcode Previews.
    func handleQuery() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard isAutoSearchEnabled else { return }

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

    /// Execute page-1 search with cache and in-flight protection.
    ///
    /// Behavior:
    /// - In **Previews**: returns stable mock data immediately.
    /// - On new query: resets pagination.
    /// - Uses cached results if available.
    /// - Avoids duplicated calls for the same query.
    /// - Updates loading/error state.
    func executeSearch(for trimmed: String) async {
        // Preview path: static mock results.
        if ProcessInfo.processInfo.isPreview {
            results = SharedPreviewMovies.moviesList
            error = nil
            return
        }

        // New query → reset pagination.
        pagination.reset()

        // Serve from cache if present.
        if let cached = cache[trimmed] {
            results = cached
            error = cached.isEmpty ? .noResults : nil
            return
        }

        // Prevent duplicate calls for the same query.
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

    /// Fetch next page when available; updates pagination state.
    func fetchNextPage() async {
        guard pagination.startFetchingNextPage(),
              let q = lastValidQuery else { return }
        do {
            let next = pagination.state.currentPage + 1
            let response = try await repository.searchMovies(query: q, page: next)
            results.append(contentsOf: response.results)
            pagination.finishFetching(page: next, totalPages: response.totalPages)
        } catch {
            pagination.cancelFetching()
            self.error = .networkFailure
        }
    }

    /// Toggle loading flag and clear errors when a load begins.
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading { error = nil }
    }

    /// Clear UI state for invalid/cleared queries.
    func resetSearchState() {
        results = []
        error = nil
        isLoading = false
    }

    /// Keep cache size under the configured limit (FIFO-ish).
    func trimCacheIfNeeded() {
        if cache.count > maxCacheSize {
            let excess = cache.count - maxCacheSize
            for key in cache.keys.prefix(excess) {
                cache.removeValue(forKey: key)
            }
        }
    }
}

#if DEBUG
extension SearchViewModel {
    /// Inject preview-only state without touching production paths.
    /// Returns `self` for fluent configuration in preview factories.
    @discardableResult
    func _previewInject(
        query: String = "",
        results: [Movie] = [],
        isLoading: Bool = false,
        error: SearchError? = nil,
        validationMessage: String? = nil,
        lastValidQuery: String? = nil,
        trimmedQuery: String = ""
    ) -> SearchViewModel {
        self.query = query
        self.results = results
        self.isLoading = isLoading
        self.error = error
        self.validationMessage = validationMessage
        self.lastValidQuery = lastValidQuery
        self.trimmedQuery = trimmedQuery
        return self
    }
}
#endif
