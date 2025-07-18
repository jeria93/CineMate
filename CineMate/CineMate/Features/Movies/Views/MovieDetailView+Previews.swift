//
//  MovieDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Previews for `MovieDetailView`, including mock data from PreviewFactory and SharedPreviewMovies.
/// - Includes `PreviewID.reset()` to ensure consistent preview IDs across runs.
extension MovieDetailView {
    static var previewDefault: some View {
        PreviewID.reset()

        return MovieDetailView(
            movie: SharedPreviewMovies.starWars,
            viewModel: PreviewFactory.movieDetailViewModelWithData(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }
}
