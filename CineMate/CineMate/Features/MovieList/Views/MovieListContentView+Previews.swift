//
//    MovieListContentView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension MovieListContentView {
    static var previewList: some View {
        let movieVM = MovieViewModel(repository: MockMovieRepository())
        movieVM.movies = PreviewData.moviesList

        return MovieListContentView(
            viewModel: movieVM,
            castViewModelProvider: {
                let castVM = CastViewModel(repository: MockMovieRepository())
                castVM.cast = PreviewData.starWarsCredits.cast
                return castVM
            }
        )
    }

    static var previewLoading: some View {
        let movieVM = MovieViewModel(repository: MockMovieRepository())
        movieVM.isLoading = true

        return MovieListContentView(
            viewModel: movieVM,
            castViewModelProvider: {
                CastViewModel(repository: MockMovieRepository())
            }
        )
    }

    static var previewError: some View {
        let movieVM = MovieViewModel(repository: MockMovieRepository())
        movieVM.errorMessage = "Oops, something went wrong."

        return MovieListContentView(
            viewModel: movieVM,
            castViewModelProvider: {
                CastViewModel(repository: MockMovieRepository())
            }
        )
    }
}
