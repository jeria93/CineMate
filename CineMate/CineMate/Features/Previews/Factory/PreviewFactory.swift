//
//  PreviewFactory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Centralized factory for generating mock ViewModels and Views for SwiftUI previews.
enum PreviewFactory {
    static let repository = MockMovieRepository()
    static let recommendedMovies = SharedPreviewMovies.moviesList

    /// ViewModel with a populated list of mock movies.
    @MainActor
    static func movieListViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }

    /// ViewModel with full movie detail and credits.
    @MainActor
    static func movieDetailViewModelWithData() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.starWarsDetail
        vm.movieCredits = PreviewData.starWarsCredits()
        return vm
    }

    /// ViewModel with only empty movie detail loaded.
    @MainActor
    static func movieDetailViewModelEmptyDetail() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.emptyDetail
        return vm
    }

    /// Empty state with no detail or credits.
    @MainActor
    static func emptyMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        return MovieViewModel(repository: repository)
    }

    /// Loading state with spinner active.
    @MainActor
    static func loadingMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    /// Error state with predefined message.
    @MainActor
    static func errorMovieViewModel() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.errorMessage = "Oops, something went wrong."
        return vm
    }

    /// ViewModel with populated recommendations only.
    @MainActor
    static func movieDetailViewModelWithRecommendations() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.recommendedMovies = recommendedMovies
        return vm
    }

    /// CastViewModel with mock cast members.
    @MainActor
    static func castViewModel() -> CastViewModel {
        resetAllPreviewData()
        let vm = CastViewModel(repository: repository)
        vm.cast = PreviewData.starWarsCredits().cast
        return vm
    }

    /// Fully configured preview for the cast member detail view.
    @MainActor
    static func castMemberDetailView() -> some View {
        resetAllPreviewData()
        return NavigationStack {
            CastMemberDetailView(
                member: CastMemberPreviewData.markHamill,
                viewModel: .preview
            )
        }
    }

    /// Movie detail view model with watch provider data.
    @MainActor
    static func movieDetailViewModelWithWatchProviders() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.watchProviderRegion = PreviewData.mockWatchProviderRegion
        return vm
    }

    /// Movie detail loading state (for detail only).
    @MainActor
    static func movieDetailViewModelLoading() -> MovieViewModel {
        resetAllPreviewData()
        let vm = MovieViewModel(repository: repository)
        vm.isLoadingDetail = true
        return vm
    }
}
