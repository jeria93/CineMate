//
//    MovieListContentView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension MovieListContentView {

    /// Preview: default list of mock movies.
    static var previewList: some View {
        MovieListContentView(
            viewModel: PreviewFactory.movieListViewModel(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }

    /// Preview: loading state.
    static var previewLoading: some View {
        MovieListContentView(
            viewModel: PreviewFactory.loadingMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel()        )
    }

    /// Preview: error state.
    static var previewError: some View {
        MovieListContentView(
            viewModel: PreviewFactory.errorMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel(),        )
    }
}
