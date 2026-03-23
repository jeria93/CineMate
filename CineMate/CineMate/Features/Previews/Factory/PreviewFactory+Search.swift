//
//  PreviewFactory+Search.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

/// Provides mock `SearchViewModel` instances for SwiftUI previews.
///
/// These helpers simulate various search states without triggering
/// network requests or debounce logic. Each method returns a configured
/// instance of `SearchViewModel` using `_previewInject` for safe state setup.
#if DEBUG
@MainActor
extension PreviewFactory {

    /// Preview showing a successful search with mock results.
    static func searchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "Star",
                results: SharedPreviewMovies.moviesList,
                isLoading: false,
                error: nil,
                lastValidQuery: "Star",
                trimmedQuery: "Star"
            )
    }

    /// Preview showing a valid query that returns no results.
    static func emptySearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "Unknown",
                results: [],
                isLoading: false,
                error: nil,
                lastValidQuery: "Unknown",
                trimmedQuery: "Unknown"
            )
    }

    /// Preview showing a search in progress (loading state).
    static func loadingSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "Loading",
                results: [],
                isLoading: true,
                error: nil,
                lastValidQuery: "Loading",
                trimmedQuery: "Loading"
            )
    }

    /// Preview showing a simulated API/network error.
    static func errorSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "Error",
                results: [],
                isLoading: false,
                error: .custom("Something went wrong"),
                lastValidQuery: "Error",
                trimmedQuery: "Error"
            )
    }

    /// Preview showing an invalid query with a validation message.
    static func invalidSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "?",
                results: [],
                isLoading: false,
                error: nil,
                validationMessage: "Use letters, numbers, spaces, and basic punctuation.",
                lastValidQuery: nil,
                trimmedQuery: ""
            )
    }

    /// Preview showing the initial idle state with an empty query.
    static func promptSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: repository)
            ._previewInject(
                query: "",
                results: [],
                isLoading: false,
                error: nil,
                lastValidQuery: nil,
                trimmedQuery: ""
            )
    }
}
#endif
