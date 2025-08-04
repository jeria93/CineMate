//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// ViewModel that drives the Search screen.
///
/// Responsibilities:
/// - Validates and debounces the user’s query to avoid spamming the API.
/// - Caches results in-memory per trimmed query to save network calls.
/// - Uses an “in-flight” guard to prevent duplicate requests for the same query while one is running.
/// - Publishes UI state (loading, errors, validation messages) for SwiftUI views.
///
/// Threading:
/// - Annotated with `@MainActor` to keep all published state mutations on the main thread.
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published
    @Published var query: String = "" {
        didSet { debounceSearch() }
    }
    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var error: SearchError?
    @Published var validationMessage: String?
    @Published var lastValidQuery: String?
    @Published var trimmedQuery: String = ""

    // MARK: - Dependencies
    internal let repository: MovieProtocol
    private var debounceTask: Task<Void, Never>?

    // MARK: - Cache & In-flight
    private var cache: [String: [Movie]] = [:]
    private var inFlight: Set<String> = []

    /// Max number of cached queries before old ones are removed
    private let maxCacheSize = 20

    // MARK: - Init
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Public entry point if you want to bypass debounce and run a search immediately.
    /// - Parameter query: Raw user input.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }

        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }
}

// MARK: - Private Helpers
private extension SearchViewModel {

    /// Cancels any ongoing debounce task and starts a new one.
    /// Waits 0.4s before validating and possibly executing the search.
    func debounceSearch() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            await self?.handleQuery()
        }
    }

    /// Validates the current `query`, updates validation UI, and triggers the search if valid.
    func handleQuery() async {
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

    /// Core search logic with cache + in-flight protection.
    func executeSearch(for trimmed: String) async {
        // 0. Skip network calls entirely in Xcode Previews
        if ProcessInfo.processInfo.isPreview {
            results = SharedPreviewMovies.moviesList
            error = nil
            return
        }

        // 1. Return cached results if available
        if let cached = cache[trimmed] {
            results = cached
            error = cached.isEmpty ? .noResults : nil
            return
        }

        // 2. Prevent duplicate in-flight requests
        guard !inFlight.contains(trimmed) else { return }
        inFlight.insert(trimmed)

        setLoading(true)

        do {
            // 3. Fetch from repository
            let fetchedResults = try await repository.searchMovies(query: trimmed)

            // 4. Insert into cache and trim if necessary
            cache[trimmed] = fetchedResults
            trimCacheIfNeeded()

            // 5. Update published results
            results = fetchedResults
            error = fetchedResults.isEmpty ? .noResults : nil
        } catch {
            results = []
            self.error = .networkFailure
        }

        // 6. Remove from in-flight and stop loading
        inFlight.remove(trimmed)
        setLoading(false)
    }

    /// Toggles loading state and clears old errors when starting a new request.
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            error = nil
        }
    }

    /// Clears visible results & states when the query is invalid.
    func resetSearchState() {
        results = []
        error = nil
        isLoading = false
    }

    /// Ensures the cache does not grow beyond `maxCacheSize`.
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
