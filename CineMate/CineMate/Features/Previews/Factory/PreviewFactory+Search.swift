//
//  PreviewFactory+Search.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

extension PreviewFactory {

    /// A default search view model with results
    @MainActor
    static func searchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Star"
        vm.results = PreviewData.moviesList
        return vm
    }

    /// An empty state search view model
    @MainActor
    static func emptySearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Unknown"
        vm.results = []
        return vm
    }

    /// A loading state for search with example query
    @MainActor
    static func loadingSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Loading"
        vm.isLoading = true
        return vm
    }

    /// An error state for search with example query
    @MainActor
    static func errorSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "Error"
        vm.error = .custom("Something went wrong")
        return vm
    }

    /// A validation error state for search
    @MainActor
    static func invalidSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel(repository: MockMovieRepository())
        vm.query = "?"
        vm.validationMessage = "Only letters and numbers are allowed."
        return vm
    }
}
