//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// ViewModel powering the **Search** screen.
/// Handles debounced input, validation, pagination, caching and
/// in-flight protection. Designed for SwiftUI + async/await with
/// clear loading/error states and preview-friendly behavior.
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published (UI)

    /// Raw text bound to the search bar. Debounced on change.
    @Published var query: String = "" { didSet { debounceSearch() } }

    /// Current search results shown by the UI.
    @Published private(set) var results: [Movie] = []

    /// Indicates that a request for page 1 is in progress.
    @Published private(set) var isLoading = false

    /// User-visible error (e.g. network failure, no results).
    @Published var error: SearchError?

    /// Validation feedback for the current query (e.g. invalid chars).
    @Published var validationMessage: String?

    /// Last query that passed validation and triggered a real search.
    @Published private(set) var lastValidQuery: String?

    /// `query` trimmed of whitespace (kept for UI and logic).
    @Published private(set) var trimmedQuery: String = ""

    // MARK: - Deps

    /// Abstraction for fetching movies (real or mocked).
    let repository: MovieProtocol

    // MARK: - Internal runtime

    /// Debounce worker for keystrokes.
    private var debounceTask: Task<Void, Never>?

    /// Simple in-memory cache: query → results.
    private var cache: [String: [Movie]] = [:]

    /// Tracks queries currently being fetched to avoid duplicates.
    private var inFlight: Set<String> = []

    /// Maximum number of cached queries kept in memory.
    private let maxCacheSize = 20

    /// Manages current/total pages and fetch state.
    private var pagination = PaginationManager()

    /// Init with a concrete repository (defaults to production).
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Manually trigger a search (e.g. retry button).
    /// - Parameter query: The raw user text.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }
        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    /// Ask for next page when the given item approaches the end.
    /// - Parameter currentItem: The row appearing near the bottom.
    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = results.index(results.endIndex, offsetBy: -5, limitedBy: results.startIndex) ?? results.startIndex
        if results.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await fetchNextPage()
        }
    }
}

// MARK: - Private
private extension SearchViewModel {

    /// Debounce keystrokes to avoid spamming the API.
    /// Skips entirely in Xcode Previews.
    func debounceSearch() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
            await self?.handleQuery()
        }
    }

    /// Validate and normalize the current query, then search if valid.
    /// Skips entirely in Xcode Previews.
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

    /// Execute page-1 search with cache and in-flight protection.
    /// - Uses cached results when available.
    /// - Updates pagination on success.
    /// - Emits `.networkFailure` on error.
    func executeSearch(for trimmed: String) async {
        // Preview path: inject stable mock results.
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

    /// Fetch the next page if available; updates pagination state.
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
