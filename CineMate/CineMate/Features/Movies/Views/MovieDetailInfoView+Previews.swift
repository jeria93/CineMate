//
//  MovieDetailInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieDetailInfoView {
    /// Preview with full detail data
    @MainActor
    static var previewWithDetail: some View {
        PreviewID.reset()
        return MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithData()
        )
        .padding()
    }

    /// Preview with empty detail data
    @MainActor
    static var previewWithEmptyDetail: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieDetailViewModelEmptyDetail()
        )
        .padding()
    }

    /// Preview showing streaming providers (e.g. Netflix)
    @MainActor
    static var previewWithProviders: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithWatchProviders()
        )
        .padding()
    }

    /// Preview when loading details
    @MainActor
    static var previewLoading: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieDetailViewModelLoading()
        )
        .padding()
    }

    /// Preview with no detail data available
    @MainActor
    static var previewNoDetail: some View {
        MovieDetailInfoView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.emptyMovieViewModel()
        )
        .padding()
    }
}
