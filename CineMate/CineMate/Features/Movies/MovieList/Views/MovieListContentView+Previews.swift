//
//    MovieListContentView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

extension MovieListContentView {
    static var previewList: some View {
        MovieListContentView(
            viewModel: PreviewFactory.movieListViewModel(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }

    static var previewLoading: some View {
        MovieListContentView(
            viewModel: PreviewFactory.loadingMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }

    static var previewError: some View {
        MovieListContentView(
            viewModel: PreviewFactory.errorMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }
}
