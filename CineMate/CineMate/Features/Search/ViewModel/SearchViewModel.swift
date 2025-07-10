//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// ViewModel responsible for managing search logic and state.
/// Validates user input, performs debounced searches via a repository,
/// and updates UI-related properties for display in the view.
@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published Properties
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
    private let repository: MovieProtocol
    private var debounceTask: Task<Void, Never>?

    // MARK: - Init

    /// Creates a new `SearchViewModel` with an optional repository.
    /// - Parameter repository: A movie repository, defaults to the live implementation.
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Search Trigger

    /// Debounces search input to avoid frequent requests.
    /// Waits 0.4 seconds after the user stops typing before validating and searching.
    private func debounceSearch() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            await self?.handleQuery()
        }
    }

    /// Manually triggers a search with the given query (e.g., on return key).
    /// - Parameter query: The query to search for.
    func search(_ query: String) async {
        let result = SearchValidator.validate(query)
        guard result.isValid, let trimmed = result.trimmed else { return }

        lastValidQuery = trimmed
        await executeSearch(for: trimmed)
    }

    // MARK: - Logic Helpers

    /// Validates the current query and initiates a search if valid.
    private func handleQuery() async {
        let result = SearchValidator.validate(query)

        trimmedQuery = result.trimmed ?? ""
        validationMessage = result.message

        if let trimmed = result.trimmed, result.isValid {
            await executeSearch(for: trimmed)
        } else {
            resetSearchState()
        }
    }

    /// Performs the actual search using the repository and updates state accordingly.
    /// - Parameter trimmed: A validated and trimmed query string.
    private func executeSearch(for trimmed: String) async {
        setLoading(true)

        do {
            let fetchedResults = try await repository.searchMovies(query: trimmed)
            results = fetchedResults
            if fetchedResults.isEmpty {
                error = .noResults
            }
        } catch {
            self.error = .networkFailure
            results = []
        }

        setLoading(false)
    }

    /// Sets loading state and clears previous error if applicable.
    /// - Parameter loading: Whether the search is loading or not.
    private func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            error = nil
        }
    }

    /// Resets the state of the search (e.g., when validation fails).
    private func resetSearchState() {
        results = []
        error = nil
        isLoading = false
    }
}
