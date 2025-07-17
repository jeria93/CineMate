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
@MainActor
extension PreviewFactory {

    /// Default state with mock search results for "Star".
    static func searchViewModel() -> SearchViewModel {
        PreviewID.reset()
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Star"
        vm.results = SharedPreviewMovies.moviesList
        return vm
    }

    /// Simulates a state where no results are found.
    static func emptySearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Unknown"
        vm.results = []
        vm.trimmedQuery = "Unknown"
        return vm
    }

    /// Simulates loading state (e.g. when fetching results).
    static func loadingSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Loading"
        vm.isLoading = true
        return vm
    }

    /// Simulates a failed search request (e.g. API/network error).
    static func errorSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Error"
        vm.error = .custom("Something went wrong")
        return vm
    }

    /// Simulates validation error (e.g. unsupported characters).
    static func invalidSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "?"
        vm.validationMessage = "Only letters and numbers are allowed."
        return vm
    }

    /// Represents the initial search prompt (empty state).
    static func promptSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = ""
        return vm
    }
}
