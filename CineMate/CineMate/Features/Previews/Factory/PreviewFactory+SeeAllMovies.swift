//
//  PreviewFactory+SeeAllMovies.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

@MainActor
extension PreviewFactory {

    /// A mock view model with populated movie list for previewing normal state.
    static func seeAllMoviesPreviewViewModel() -> SeeAllMoviesViewModel {
        let vm = SeeAllMoviesViewModel(
            repository: repository,
            filter: DiscoverFilter()
        )
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }

    /// A mock view model simulating a loading state (initial or paginated).
    static func seeAllMoviesLoadingViewModel() -> SeeAllMoviesViewModel {
        let vm = SeeAllMoviesViewModel(
            repository: repository,
            filter: DiscoverFilter()
        )
        vm.isLoading = true
        return vm
    }

    /// A mock view model simulating an error state with a message.
    static func seeAllMoviesErrorViewModel() -> SeeAllMoviesViewModel {
        let vm = SeeAllMoviesViewModel(
            repository: repository,
            filter: DiscoverFilter()
        )
        vm.errorMessage = "Something went wrong. Please try again."
        return vm
    }

    /// A mock view model representing an empty state with no results.
    static func seeAllMoviesEmptyViewModel() -> SeeAllMoviesViewModel {
        SeeAllMoviesViewModel(
            repository: repository,
            filter: DiscoverFilter()
        )
    }
}

/// Backward-compatible conveniences used by existing `#Preview` declarations.
@MainActor
extension SeeAllMoviesViewModel {
    static var preview: SeeAllMoviesViewModel { PreviewFactory.seeAllMoviesPreviewViewModel() }
    static var loading: SeeAllMoviesViewModel { PreviewFactory.seeAllMoviesLoadingViewModel() }
    static var error: SeeAllMoviesViewModel { PreviewFactory.seeAllMoviesErrorViewModel() }
    static var empty: SeeAllMoviesViewModel { PreviewFactory.seeAllMoviesEmptyViewModel() }
}
