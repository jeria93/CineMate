//
//  PreviewFactory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import Foundation
import SwiftUI

enum PreviewFactory {
    static let repository = MockMovieRepository()
    static let recommendedMovies = PreviewData.moviesList

    // MARK: - MovieViewModel States

    @MainActor
    static func movieListViewModel() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movies = PreviewData.moviesList
        return vm
    }

    @MainActor
    static func movieDetailViewModelWithData() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.starWarsDetail
        vm.movieCredits = PreviewData.starWarsCredits
        return vm
    }

    @MainActor
    static func movieDetailViewModelEmptyDetail() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.emptyDetail
        return vm
    }

    @MainActor
    static func emptyMovieViewModel() -> MovieViewModel {
        MovieViewModel(repository: repository)
    }

    @MainActor
    static func loadingMovieViewModel() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    @MainActor
    static func errorMovieViewModel() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.errorMessage = "Oops, something went wrong."
        return vm
    }

    // MARK: - MovieViewModel with recommendations

    @MainActor
    static func movieDetailViewModelWithRecommendations() -> MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.recommendedMovies = recommendedMovies
        return vm
    }

    // MARK: - CastViewModel Provider

    @MainActor
    static func castViewModelProvider() -> () -> CastViewModel {
        { CastViewModel(repository: repository) }
    }

    // MARK: - PersonViewModel

    @MainActor
    static func personViewModel() -> PersonViewModel {
        let vm = PersonViewModel(repository: repository)
        vm.personDetail = PreviewData.markHamillPersonDetail
        vm.personMovies = PreviewData.markHamillMovies
        return vm
    }

    // MARK: - CastViewModel

    @MainActor
    static func castViewModel() -> CastViewModel {
        let vm = CastViewModel(repository: repository)
        vm.cast = PreviewData.starWarsCredits.cast
        return vm
    }

    // MARK: - CastMemberDetailView

    @MainActor
    static func castMemberDetailView() -> some View {
        NavigationStack {
            CastMemberDetailView(
                member: PreviewData.markHamill,
                viewModel: personViewModel()
            )
        }
    }
}
