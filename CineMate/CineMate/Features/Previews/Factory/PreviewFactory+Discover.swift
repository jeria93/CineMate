//
//  PreviewFactory+Discover.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Provides preconfigured `DiscoverViewModel` instances for SwiftUI previews.
/// Useful for previewing different UI states without triggering real network calls.
extension PreviewFactory {

    /// A default DiscoverViewModel with mock movie results.
    /// Used to preview the normal loaded state.
    @MainActor
    static func discoverViewModel() -> DiscoverViewModel {
        let vm = DiscoverViewModel(repository: MockMovieRepository())
        vm.results = PreviewData.moviesList
        vm.isLoading = false
        vm.error = nil
        return vm
    }

    /// A DiscoverViewModel in a loading state.
    /// Used to preview loading indicators.
    @MainActor
    static func loadingDiscoverViewModel() -> DiscoverViewModel {
        let vm = DiscoverViewModel(repository: MockMovieRepository())
        vm.isLoading = true
        vm.results = []
        vm.error = nil
        return vm
    }

    /// A DiscoverViewModel with no results.
    /// Used to preview the empty state UI.
    @MainActor
    static func emptyDiscoverViewModel() -> DiscoverViewModel {
        let vm = DiscoverViewModel(repository: MockMovieRepository())
        vm.results = []
        vm.isLoading = false
        vm.error = nil
        return vm
    }

    /// A DiscoverViewModel simulating an error.
    /// Used to preview error message UI.
    @MainActor
    static func errorDiscoverViewModel() -> DiscoverViewModel {
        let vm = DiscoverViewModel(repository: MockMovieRepository())
        vm.results = []
        vm.isLoading = false
        vm.error = .custom("Something went wrong")
        return vm
    }
}
