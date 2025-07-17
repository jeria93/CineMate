//
//  PreviewFactory+Search.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

/// Preview factory helpers for `SearchViewModel`.
///
/// Simulates various UI states for the search feature:
/// - Default (successful search)
/// - Empty (no results)
/// - Loading (spinner)
/// - Error (API failure)
/// - Invalid (query validation)
/// - Prompt (initial idle state)
extension PreviewFactory {

    /// Default state with mock search results for "Star".
    ///
    /// Useful for previews with populated search lists.
    @MainActor
    static func searchViewModel() -> SearchViewModel {
        PreviewID.reset()
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Star"
        vm.results = SharedPreviewMovies.moviesList
        return vm
    }

    /// Simulates a state where no results are found.
    ///
    /// Good for testing "No results" empty views.
    @MainActor
    static func emptySearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Unknown"
        vm.results = []
        vm.trimmedQuery = "Unknown"
        return vm
    }

    /// Simulates loading state (e.g. when fetching results).
    ///
    /// Can be used to preview spinners or shimmer effects.
    @MainActor
    static func loadingSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Loading"
        vm.isLoading = true
        return vm
    }

    /// Simulates a failed search request (e.g. API/network error).
    ///
    /// Use this to test error banners or fallback messages.
    @MainActor
    static func errorSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Error"
        vm.error = .custom("Something went wrong")
        return vm
    }

    /// Simulates validation error (e.g. unsupported characters).
    ///
    /// Example: entering symbols that aren’t allowed.
    @MainActor
    static func invalidSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "?"
        vm.validationMessage = "Only letters and numbers are allowed."
        return vm
    }

    /// Represents the initial search prompt (empty state).
    ///
    /// Used when no query has been entered yet.
    @MainActor
    static func promptSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = ""
        return vm
    }
}
