//
//  MovieDetailInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieDetailInfoView {
    @MainActor
    static var previewWithDetail: some View {
        MovieDetailInfoView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithData()
        )
        .padding()
    }

    @MainActor
    static var previewWithEmptyDetail: some View {
        MovieDetailInfoView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelEmptyDetail()
        )
        .padding()
    }
}
