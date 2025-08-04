//
//  PreviewFactory+Search.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

/// Preview factory helpers for `SearchViewModel`.
///
/// Provides **preconfigured view models** for SwiftUI previews, allowing
/// you to visualize all UI states of the Search feature without triggering
/// network requests or debounce logic.
///
/// States covered:
/// - `previewDefault`  → Successful search with results
/// - `previewEmpty`    → No results for a valid query
/// - `previewLoading`  → Search in progress (spinner)
/// - `previewError`    → Simulated network/API failure
/// - `previewValidation` → Invalid query with validation message
/// - `previewPrompt`   → Initial idle state (empty query)
///
/// All previews:
/// - Disable `isLoading` except for the loading state
/// - Avoid triggering `executeSearch`
/// - Set `error` or `results` explicitly for a deterministic UI
@MainActor
extension PreviewFactory {

    /// Default state with mock search results for "Star".
    /// - Shows the list of movies and no error.
    static func searchViewModel() -> SearchViewModel {
        PreviewID.reset()
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Star"
        vm.results = SharedPreviewMovies.moviesList
        vm.isLoading = false
        vm.error = nil
        return vm
    }

    /// Simulates an empty result for a valid query.
    /// - Query is "Unknown" with no matching movies.
    static func emptySearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Unknown"
        vm.results = []
        vm.trimmedQuery = "Unknown"
        vm.isLoading = false
        vm.error = nil
        return vm
    }

    /// Simulates a loading state.
    /// - Query is "Loading", spinner is visible.
    static func loadingSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Loading"
        vm.results = []
        vm.isLoading = true
        vm.error = nil
        return vm
    }

    /// Simulates a failed search request (network or API error).
    /// - Query is "Error", shows an error message.
    static func errorSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Error"
        vm.results = []
        vm.isLoading = false
        vm.error = .custom("Something went wrong")
        return vm
    }

    /// Simulates a validation error for an invalid query.
    /// - Query is "?" and shows a red validation message.
    static func invalidSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "?"
        vm.results = []
        vm.isLoading = false
        vm.validationMessage = "Only letters and numbers are allowed."
        return vm
    }

    /// Represents the initial search prompt (empty input).
    /// - Query is empty, shows the friendly prompt.
    static func promptSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = ""
        vm.results = []
        vm.isLoading = false
        vm.error = nil
        return vm
    }
}
