//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// UI states for search content rendering.
enum SearchViewState: Equatable {
    case prompt
    case validationError
    case loading
    case results
    case empty
    case networkError
}

/// Drives the Search screen:
/// - Safe debounce with stale-response protection
/// - Clear separation of prompt/loading/validation/error/empty/results states
/// - In-flight guards for duplicate calls
/// - Infinite scrolling only near list end
/// - Simple bounded LRU in-memory cache
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published state

    /// Raw text from SearchBarView. Debounced on change.
    @Published var query: String = "" { didSet { debounceSearch() } }

    /// Search results shown in the list.
    @Published private(set) var results: [Movie] = []

    /// True while first page is loading.
    @Published private(set) var isLoading = false

    /// True while a next page fetch is loading.
    @Published private(set) var isLoadingNextPage = false

    /// Active state used by SearchView rendering.
    @Published private(set) var state: SearchViewState = .prompt

    /// Network error for retry UI.
    @Published private(set) var error: SearchError?

    /// Validation message shown under the search bar.
    @Published private(set) var validationMessage: String?

    /// Auto-search toggle for text changes.
    @Published var isAutoSearchEnabled: Bool = true

    /// Guest lock: blocks manual/automatic searches.
    @Published private(set) var isInteractionLocked = false

    /// Latest valid normalized query.
    @Published private(set) var lastValidQuery: String?

    /// Latest normalized/trimmed query (for UI copy).
    @Published private(set) var trimmedQuery: String = ""

    // MARK: - Dependencies

    /// Abstraction for data fetches.
    let repository: MovieProtocol

    // MARK: - Runtime

    private let isPreviewEnvironment: Bool
    private let debounceDelayNanos: UInt64 = 400_000_000

    private var debounceTask: Task<Void, Never>?
    private var currentSearchTask: Task<MovieResult, Error>?
    private var nextPageTask: Task<MovieResult, Error>?

    /// Prevents duplicate request keys (`query + page`).
    private var inFlightRequests: Set<SearchRequestKey> = []

    /// Bounded in-memory LRU cache.
    private var cache = SearchResultCache(limit: 20)

    /// Manages current/total pages + next-page fetch flag.
    private var pagination = PaginationManager()
    private var activeQuery: String?
    private var activeSearchGeneration: UInt64 = 0

    // MARK: - Init

    init(
        repository: MovieProtocol = MovieRepository(),
        isPreviewEnvironment: Bool = ProcessInfo.processInfo.isPreview
    ) {
        self.repository = repository
        self.isPreviewEnvironment = isPreviewEnvironment
    }

    // MARK: - Public API

    func search(_ query: String) async {
        guard !isInteractionLocked else { return }
        debounceTask?.cancel()

        if isPreviewEnvironment {
            applyPreviewState(for: query)
            return
        }
        await performSearchFlow(for: query, bypassCache: false)
    }

    func retryLastSearch() async {
        guard !isInteractionLocked else { return }

        let retryCandidate = lastValidQuery ?? query
        guard !retryCandidate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        if isPreviewEnvironment {
            applyPreviewState(for: retryCandidate)
            return
        }
        await performSearchFlow(for: retryCandidate, bypassCache: true)
    }

    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard !isPreviewEnvironment else { return }
        guard !isInteractionLocked else { return }
        guard let currentItem = currentItem else { return }
        guard state == .results else { return }
        guard shouldLoadNextPage(for: currentItem), let activeQuery else { return }

        await fetchNextPage(for: activeQuery)
    }

    func configureGuestMode(isGuest: Bool) {
        guard isGuest != isInteractionLocked else { return }

        isInteractionLocked = isGuest
        isAutoSearchEnabled = !isGuest

        guard isGuest else { return }

        invalidateSearchContext(clearCache: true)
        query = ""
        trimmedQuery = ""
        lastValidQuery = nil
        validationMessage = nil
        error = nil
        results = []
        state = .prompt
    }

    /// Debounces typing to avoid request spam.
    func debounceSearch() {
        debounceTask?.cancel()
        guard !isPreviewEnvironment else { return }
        guard isAutoSearchEnabled, !isInteractionLocked else { return }

        let snapshot = query
        let delay = debounceDelayNanos
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            await self?.runDebouncedSearch(for: snapshot)
        }
    }
}

// MARK: - Private
private extension SearchViewModel {

    func runDebouncedSearch(for snapshot: String) async {
        guard snapshot == query else { return }
        await performSearchFlow(for: snapshot, bypassCache: false)
    }

    func performSearchFlow(for rawQuery: String, bypassCache: Bool) async {
        let result = SearchValidator.validate(rawQuery)
        trimmedQuery = result.trimmed ?? ""
        validationMessage = result.message

        switch result {
        case .empty:
            resetSearchState()
        case .tooShort, .tooLong, .invalidCharacters:
            applyValidationErrorState()
        case .valid(let trimmed):
            lastValidQuery = trimmed
            await executeSearch(for: trimmed, bypassCache: bypassCache)
        }
    }

    func executeSearch(for trimmed: String, bypassCache: Bool) async {
        let requestKey = SearchRequestKey(query: trimmed, page: 1)
        guard !inFlightRequests.contains(requestKey) else { return }

        let generation = startSearchSession(for: trimmed)

        if !bypassCache, let cached = cache.value(for: trimmed) {
            applyCachedState(cached, query: trimmed)
            return
        }

        inFlightRequests.insert(requestKey)
        setLoadingState()

        defer {
            inFlightRequests.remove(requestKey)
            if canApply(generation: generation, query: trimmed) {
                isLoading = false
            }
        }

        let task = Task { [repository] in
            try await repository.searchMovies(query: trimmed, page: 1)
        }
        currentSearchTask = task

        do {
            let response = try await task.value
            guard canApply(generation: generation, query: trimmed) else { return }

            applyFirstPageState(response, query: trimmed)
        } catch is CancellationError {
            return
        } catch {
            guard canApply(generation: generation, query: trimmed) else { return }
            applyNetworkErrorState()
        }
    }

    func fetchNextPage(for query: String) async {
        guard pagination.startFetchingNextPage() else { return }

        let nextPage = pagination.state.currentPage + 1
        let requestKey = SearchRequestKey(query: query, page: nextPage)
        guard !inFlightRequests.contains(requestKey) else {
            pagination.cancelFetching()
            return
        }

        let generation = activeSearchGeneration
        inFlightRequests.insert(requestKey)
        isLoadingNextPage = true
        error = nil

        defer {
            inFlightRequests.remove(requestKey)
            if canApply(generation: generation, query: query) {
                isLoadingNextPage = false
            }
        }

        let task = Task { [repository] in
            try await repository.searchMovies(query: query, page: nextPage)
        }
        nextPageTask = task

        do {
            let response = try await task.value
            guard canApply(generation: generation, query: query) else { return }

            appendUnique(response.results)
            pagination.finishFetching(page: nextPage, totalPages: response.totalPages)
            cache.set(
                CachedSearchEntry(
                    movies: results,
                    currentPage: pagination.state.currentPage,
                    totalPages: pagination.state.totalPages
                ),
                for: query
            )
            state = results.isEmpty ? .empty : .results
        } catch {
            guard canApply(generation: generation, query: query) else { return }
            pagination.cancelFetching()

            if results.isEmpty {
                applyNetworkErrorState()
            } else {
                state = .results
            }
        }
    }

    func shouldLoadNextPage(for currentItem: Movie) -> Bool {
        guard pagination.hasMorePages else { return false }
        guard !pagination.isFetching, !isLoading, !isLoadingNextPage else { return false }
        guard let index = results.firstIndex(where: { $0.id == currentItem.id }) else { return false }

        let threshold = max(results.count - 3, 0)
        return index >= threshold
    }

    func appendUnique(_ incoming: [Movie]) {
        var seen = Set(results.map(\.id))
        let unique = incoming.filter { seen.insert($0.id).inserted }
        results.append(contentsOf: unique)
    }

    func startSearchSession(for query: String) -> UInt64 {
        activeSearchGeneration &+= 1
        activeQuery = query
        currentSearchTask?.cancel()
        nextPageTask?.cancel()
        pagination.reset()
        isLoadingNextPage = false
        return activeSearchGeneration
    }

    func canApply(generation: UInt64, query: String) -> Bool {
        generation == activeSearchGeneration && activeQuery == query
    }

    func setLoadingState() {
        isLoading = true
        isLoadingNextPage = false
        error = nil
        state = .loading
        results = []
    }

    func applyFirstPageState(_ response: MovieResult, query: String) {
        let totalPages = max(1, response.totalPages)
        results = response.results
        error = nil
        state = response.results.isEmpty ? .empty : .results
        pagination.finishFetching(page: 1, totalPages: totalPages)
        cache.set(
            CachedSearchEntry(
                movies: response.results,
                currentPage: 1,
                totalPages: totalPages
            ),
            for: query
        )
    }

    func applyCachedState(_ cached: CachedSearchEntry, query: String) {
        results = cached.movies
        error = nil
        validationMessage = nil
        isLoading = false
        isLoadingNextPage = false
        pagination.finishFetching(page: cached.currentPage, totalPages: cached.totalPages)
        state = cached.movies.isEmpty ? .empty : .results
        activeQuery = query
    }

    func applyValidationErrorState() {
        invalidateSearchContext(clearCache: false)
        results = []
        error = nil
        state = .validationError
    }

    func applyNetworkErrorState() {
        results = []
        error = .networkFailure
        state = .networkError
        pagination.reset()
    }

    func resetSearchState() {
        invalidateSearchContext(clearCache: false)
        trimmedQuery = ""
        lastValidQuery = nil
        results = []
        error = nil
        validationMessage = nil
        state = .prompt
    }

    func invalidateSearchContext(clearCache: Bool) {
        activeSearchGeneration &+= 1
        activeQuery = nil
        debounceTask?.cancel()
        currentSearchTask?.cancel()
        nextPageTask?.cancel()
        inFlightRequests.removeAll()
        pagination.reset()
        isLoading = false
        isLoadingNextPage = false
        if clearCache {
            cache.clear()
        }
    }

    func applyPreviewState(for rawQuery: String) {
        let result = SearchValidator.validate(rawQuery)
        trimmedQuery = result.trimmed ?? ""
        validationMessage = result.message
        isLoading = false
        isLoadingNextPage = false
        error = nil
        pagination.reset()

        switch result {
        case .empty:
            results = []
            lastValidQuery = nil
            state = .prompt
        case .tooShort, .tooLong, .invalidCharacters:
            results = []
            lastValidQuery = nil
            state = .validationError
        case .valid(let trimmed):
            results = SharedPreviewMovies.moviesList
            lastValidQuery = trimmed
            state = results.isEmpty ? .empty : .results
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
        isLoadingNextPage: Bool = false,
        state: SearchViewState? = nil,
        error: SearchError? = nil,
        validationMessage: String? = nil,
        lastValidQuery: String? = nil,
        trimmedQuery: String = "",
        isInteractionLocked: Bool = false,
        isAutoSearchEnabled: Bool = true
    ) -> SearchViewModel {
        self.query = query
        self.results = results
        self.isLoading = isLoading
        self.isLoadingNextPage = isLoadingNextPage
        self.error = error
        self.validationMessage = validationMessage
        self.lastValidQuery = lastValidQuery
        self.trimmedQuery = trimmedQuery
        self.isInteractionLocked = isInteractionLocked
        self.isAutoSearchEnabled = isAutoSearchEnabled
        self.state = state ?? Self.resolvePreviewState(
            isLoading: isLoading,
            error: error,
            validationMessage: validationMessage,
            results: results,
            trimmedQuery: trimmedQuery
        )
        return self
    }

    static func resolvePreviewState(
        isLoading: Bool,
        error: SearchError?,
        validationMessage: String?,
        results: [Movie],
        trimmedQuery: String
    ) -> SearchViewState {
        if isLoading { return .loading }
        if validationMessage != nil { return .validationError }
        if error != nil { return .networkError }
        if results.isEmpty && !trimmedQuery.isEmpty { return .empty }
        if results.isEmpty { return .prompt }
        return .results
    }
}
#endif

// MARK: - Helpers
private struct SearchRequestKey: Hashable {
    let query: String
    let page: Int
}

private struct CachedSearchEntry {
    let movies: [Movie]
    let currentPage: Int
    let totalPages: Int
}

private struct SearchResultCache {
    private let limit: Int
    private var storage: [String: CachedSearchEntry] = [:]
    private var accessOrder: [String] = []

    init(limit: Int) {
        self.limit = max(1, limit)
    }

    mutating func value(for query: String) -> CachedSearchEntry? {
        guard let entry = storage[query] else { return nil }
        moveToMostRecent(query)
        return entry
    }

    mutating func set(_ entry: CachedSearchEntry, for query: String) {
        storage[query] = entry
        moveToMostRecent(query)

        while accessOrder.count > limit {
            let oldest = accessOrder.removeFirst()
            storage.removeValue(forKey: oldest)
        }
    }

    mutating func clear() {
        storage.removeAll()
        accessOrder.removeAll()
    }

    private mutating func moveToMostRecent(_ query: String) {
        accessOrder.removeAll(where: { $0 == query })
        accessOrder.append(query)
    }
}
