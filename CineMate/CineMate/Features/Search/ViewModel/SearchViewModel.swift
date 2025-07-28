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

    // MARK: - Init
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Debounce

    /// Cancels any ongoing debounce task and starts a new one.
    /// Waits 0.4s before validating and possibly executing the search.
    private func debounceSearch() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            await self?.handleQuery()
        }
    }

    // MARK: - Validation & Dispatch

    /// Validates the current `query`, updates validation UI, and triggers the search if valid.
    private func handleQuery() async {
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

    /// Public entry point if you want to bypass debounce and run a search immediately.
    /// - Parameter query: Raw user input.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }

        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    // MARK: - Search
    private func executeSearch(for trimmed: String) async {
        if let cached = cache[trimmed] {
            results = cached
            error = cached.isEmpty ? .noResults : nil
            return
        }

        guard !inFlight.contains(trimmed) else { return }
        inFlight.insert(trimmed)
        setLoading(true)

        do {
            let fetchedResults = try await repository.searchMovies(query: trimmed)
            cache[trimmed] = fetchedResults
            results = fetchedResults
            error = fetchedResults.isEmpty ? .noResults : nil
        } catch {
            results = []
            self.error = .networkFailure
        }

        inFlight.remove(trimmed)
        setLoading(false)
    }

    /// Toggles loading state and clears old errors when starting a new request.
    private func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            error = nil
        }
    }
    /// Clears visible results & states when the query is invalid.
    private func resetSearchState() {
        results = []
        error = nil
        isLoading = false
    }
}
