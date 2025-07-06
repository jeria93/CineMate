//
//  PreviewFactory+Search.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

extension PreviewFactory {

    /// A default search view model (extend with data later)
    @MainActor
    static func searchViewModel() -> SearchViewModel {
        SearchViewModel()
    }

    /// An empty state search view model (if needed)
    @MainActor
    static func emptySearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel()
        // vm.results = [] // Example if you add a results array
        return vm
    }

    /// A loading state for search (if needed)
    @MainActor
    static func loadingSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel()
        // vm.isLoading = true
        return vm
    }

    /// An error state for search (if needed)
    @MainActor
    static func errorSearchViewModel() -> SearchViewModel {
        let vm = SearchViewModel()
        // vm.errorMessage = "Something went wrong"
        return vm
    }
}
