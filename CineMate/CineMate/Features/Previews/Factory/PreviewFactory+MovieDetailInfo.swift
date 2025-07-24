//
//  PreviewFactory+MovieDetailInfo.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-23.
//

import Foundation

@MainActor
extension PreviewFactory {

    /// ViewModel with full movie detail and genres.
    static var movieViewModelWithDetail: MovieViewModel {
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.movieDetail = MovieDetailPreviewData.starWarsDetail
        return vm
    }

    /// ViewModel with empty genres and no detail fields.
    static var movieViewModelWithEmptyDetail: MovieViewModel {
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.movieDetail = MovieDetailPreviewData.emptyDetail
        return vm
    }

    /// ViewModel in loading state (simulates detail being fetched).
    static var movieViewModelLoading: MovieViewModel {
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.isLoadingDetail = true
        return vm
    }

    /// ViewModel with watch provider region set.
//    static var movieViewModelWithProviders: MovieViewModel {
//        let vm = MovieViewModel(repository: MockMovieRepository())
//        vm.watchProviderRegion = WatchProviderPreviewData.defaultRegion
//        return vm
//    }

    /// ViewModel without any movie detail set (fallback UI).
    static var movieViewModelWithoutDetail: MovieViewModel {
        MovieViewModel(repository: MockMovieRepository())
    }
}
