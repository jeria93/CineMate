//
//  PreviewFactory+MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Previews for movie list/detail view models.
@MainActor
extension PreviewFactory {

    // MARK: - MovieViewModel (List)

    /// List with mock movies.
    static func movieListViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movies = SharedPreviewMovies.moviesList.removingDuplicateIDs()
        return vm
    }

    /// Empty state (no data).
    static func emptyMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        return MovieViewModel(repository: repository)
    }

    /// Loading spinner state.
    static func loadingMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    /// Error message state.
    static func errorMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.errorMessage = "Oops, something went wrong."
        return vm
    }

    // MARK: - MovieDetailViewModel (Detail)

    /// Detail with full mock data.
    static func movieDetailViewModelWithData() -> MovieDetailViewModel {
        resetAllPreviewData()
        let vm = MovieDetailViewModel(repository: repository)
        vm.movieDetail = MovieDetailPreviewData.starWarsDetail
        vm.movieVideos = PreviewData.sampleVideos
        vm.recommendedMovies = recommendedMovies
        vm.watchProvidersState = .loaded(PreviewData.mockWatchProviderAvailability)
        vm.state = .loaded
        return vm
    }

    /// Detail with empty data only.
    static func movieDetailViewModelEmptyDetail() -> MovieDetailViewModel {
        resetAllPreviewData()
        let vm = MovieDetailViewModel(repository: repository)
        vm.movieDetail = MovieDetailPreviewData.emptyDetail
        vm.state = .loaded
        return vm
    }
    
    /// Detail with only recommendations loaded.
    static func movieDetailViewModelWithRecommendations() -> MovieDetailViewModel {
        resetAllPreviewData()
        let vm = MovieDetailViewModel(repository: repository)
        vm.recommendedMovies = recommendedMovies
        vm.state = .loaded
        return vm
    }

    /// Detail with watch providers loaded.
    static func movieDetailViewModelWithWatchProviders() -> MovieDetailViewModel {
        resetAllPreviewData()
        let vm = MovieDetailViewModel(repository: repository)
        vm.watchProvidersState = .loaded(PreviewData.mockWatchProviderAvailability)
        vm.state = .loaded
        return vm
    }

    /// Loading just the detail section.
    static func movieDetailViewModelLoading() -> MovieDetailViewModel {
        resetAllPreviewData()
        let vm = MovieDetailViewModel(repository: repository)
        vm.state = .loading
        return vm
    }
}
