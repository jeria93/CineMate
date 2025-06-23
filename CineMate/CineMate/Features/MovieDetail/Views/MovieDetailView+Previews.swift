//
//  MovieDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieDetailView {
    static var previewStarWars: some View {
        MovieDetailView(
            movie: PreviewData.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithData,
            castViewModel: PreviewFactory.castViewModel
        )
    }
}
