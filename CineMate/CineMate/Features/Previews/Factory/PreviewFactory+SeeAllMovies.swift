//
//  PreviewFactory+SeeAllMovies.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

/// Preview factory extension for creating mock states of `SeeAllMoviesViewModel`.
/// These static properties provide common UI preview scenarios for SwiftUI views.
///
/// Usage:
/// - `.preview`: Shows a list of mock movies
/// - `.loading`: Simulates a loading state
/// - `.error`: Simulates an error state
/// - `.empty`: Represents an empty result state
extension SeeAllMoviesViewModel {

    /// A mock view model with populated movie list for previewing normal state.
    static var preview: SeeAllMoviesViewModel {
        PreviewID.reset()
        let viewModel = SeeAllMoviesViewModel(
            repository: MockMovieRepository(),
            filter: DiscoverFilter()
        )
        viewModel.movies = SharedPreviewMovies.moviesList
        return viewModel
    }

    /// A mock view model simulating a loading state.
    static var loading: SeeAllMoviesViewModel {
        let viewModel = SeeAllMoviesViewModel(repository: MockMovieRepository(), filter: DiscoverFilter())
        viewModel.isLoading = true
        return viewModel
    }

    /// A mock view model simulating an error state.
    static var error: SeeAllMoviesViewModel {
        let viewModel = SeeAllMoviesViewModel(repository: MockMovieRepository(), filter: DiscoverFilter())
        viewModel.hasError = true
        viewModel.errorMessage = "Something went wrong."
        return viewModel
    }

    /// A mock view model representing an empty state with no results.
    static var empty: SeeAllMoviesViewModel {
        SeeAllMoviesViewModel(repository: MockMovieRepository(), filter: DiscoverFilter())
    }
}
