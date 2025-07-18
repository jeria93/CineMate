//
//  PreviewFactory+MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Previews for various states of `MovieViewModel`
@MainActor
extension PreviewFactory {

    /// List with mock movies
    static func movieListViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }

    /// Detail with full mock data (incl. credits)
    static func movieDetailViewModelWithData() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.starWarsDetail
        vm.movieCredits = PreviewData.starWarsCredits()
        return vm
    }

    /// Detail with empty data only
    static func movieDetailViewModelEmptyDetail() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.emptyDetail
        return vm
    }

    /// Empty state (no data)
    static func emptyMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        return MovieViewModel(repository: repository)
    }

    /// Loading spinner state
    static func loadingMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    /// Error message state
    static func errorMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.errorMessage = "Oops, something went wrong."
        return vm
    }

    /// Only recommended movies loaded
    static func movieDetailViewModelWithRecommendations() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.recommendedMovies = recommendedMovies
        return vm
    }

    /// Detail with mock watch providers
    static func movieDetailViewModelWithWatchProviders() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.watchProviderRegion = PreviewData.mockWatchProviderRegion
        return vm
    }

    /// Loading just the detail section
    static func movieDetailViewModelLoading() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.isLoadingDetail = true
        return vm
    }
}
