//
//  PreviewFactory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import Foundation

enum PreviewFactory {

    // MARK: - Shared Repository
    static let repository = MockMovieRepository()

    // MARK: - MovieViewModel States

    /// Contains loaded movie list
    @MainActor
    static var movieListViewModel: MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movies = PreviewData.moviesList
        return vm
    }

    /// Contains full movie detail and credits
    @MainActor
    static var movieDetailViewModelWithData: MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.starWarsDetail
        vm.movieCredits = PreviewData.starWarsCredits
        return vm
    }

    /// Movie detail exists, but minimal/empty content
    @MainActor
    static var movieDetailViewModelEmptyDetail: MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.movieDetail = PreviewData.emptyDetail
        return vm
    }

    /// No data loaded – used for neutral/empty previews
    @MainActor
    static var emptyMovieViewModel: MovieViewModel {
        MovieViewModel(repository: repository)
    }

    /// Simulates loading state
    @MainActor
    static var loadingMovieViewModel: MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.isLoading = true
        return vm
    }

    /// Simulates error state
    @MainActor
    static var errorMovieViewModel: MovieViewModel {
        let vm = MovieViewModel(repository: repository)
        vm.errorMessage = "Oops, something went wrong."
        return vm
    }

    // MARK: - CastViewModel

    @MainActor
    static var castViewModel: CastViewModel {
        let vm = CastViewModel(repository: repository)
        vm.cast = PreviewData.starWarsCredits.cast
        return vm
    }

    // MARK: - PersonViewModel

    @MainActor
    static var personViewModel: PersonViewModel {
        let vm = PersonViewModel(repository: repository)
        vm.personDetail = PreviewData.markHamillPersonDetail
        vm.personMovies = PreviewData.markHamillMovies
        return vm
    }
}
