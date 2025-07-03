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
        MovieDetailInfoView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithData()
        )
        .padding()
    }

    /// Preview with empty detail data
    @MainActor
    static var previewWithEmptyDetail: some View {
        MovieDetailInfoView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelEmptyDetail()
        )
        .padding()
    }

    /// Preview showing streaming providers (e.g. Netflix)
    @MainActor
    static var previewWithProviders: some View {
        MovieDetailInfoView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithWatchProviders()
        )
        .padding()
    }
}
