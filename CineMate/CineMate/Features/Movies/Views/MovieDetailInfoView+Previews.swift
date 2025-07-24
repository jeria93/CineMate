//
//  MovieDetailInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

@MainActor
extension MovieDetailInfoView {
    /// Preview with full detail data
    static var previewWithDetail: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieViewModelWithDetail
        )
        .padding()
    }

    /// Preview with empty detail data
    static var previewWithEmptyDetail: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieViewModelWithEmptyDetail
        )
        .padding()
    }

    /// Preview showing streaming providers (e.g. Netflix)
//    static var previewWithProviders: some View {
//        MovieDetailInfoView(
//            movie: SharedPreviewMovies.starWars,
//            viewModel: PreviewFactory.movieViewModelWithProviders
//        )
//        .padding()
//    }

    /// Preview when loading details
    static var previewLoading: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieViewModelLoading
        )
        .padding()
    }

    /// Preview with no detail data available
    static var previewNoDetail: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieViewModelWithoutDetail
        )
        .padding()
    }
}
