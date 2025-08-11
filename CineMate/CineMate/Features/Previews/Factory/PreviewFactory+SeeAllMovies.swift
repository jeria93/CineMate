//
//  PreviewFactory+SeeAllMovies.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

/// Preview factory extension for creating mock states of `SeeAllMoviesViewModel`.
/// Provides a set of common UI preview scenarios for SwiftUI views.
///
/// ### Usage
/// ```swift
/// SeeAllMoviesView(movieViewModel: .preview, title: "Popular Movies")
/// SeeAllMoviesView(movieViewModel: .loading, title: "Loading…")
/// SeeAllMoviesView(movieViewModel: .error, title: "Error")
/// SeeAllMoviesView(movieViewModel: .empty, title: "Empty State")
/// ```
@MainActor
extension SeeAllMoviesViewModel {

    /// A mock view model with populated movie list for previewing normal state.
    static var preview: SeeAllMoviesViewModel {
        PreviewID.reset()
        let vm = SeeAllMoviesViewModel(
            repository: MockMovieRepository(),
            filter: DiscoverFilter()
        )
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }

    /// A mock view model simulating a loading state (initial or paginated).
    static var loading: SeeAllMoviesViewModel {
        let vm = SeeAllMoviesViewModel(
            repository: MockMovieRepository(),
            filter: DiscoverFilter()
        )
        vm.isLoading = true
        return vm
    }

    /// A mock view model simulating an error state with a message.
    static var error: SeeAllMoviesViewModel {
        let vm = SeeAllMoviesViewModel(
            repository: MockMovieRepository(),
            filter: DiscoverFilter()
        )
        vm.errorMessage = "Something went wrong. Please try again."
        return vm
    }

    /// A mock view model representing an empty state with no results.
    static var empty: SeeAllMoviesViewModel {
        SeeAllMoviesViewModel(
            repository: MockMovieRepository(),
            filter: DiscoverFilter()
        )
    }
}
