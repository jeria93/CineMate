//
//  MovieDetailView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Previews for `MovieDetailView` using deterministic local preview state.
extension MovieDetailView {
    @MainActor
    static var previewDefault: some View {
        PreviewID.reset()

        return MovieDetailView(
            movieId: SharedPreviewMovies.starWars.id,
            movieViewModel: PreviewFactory.movieListViewModel(),
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel(),
            detailViewModel: PreviewFactory.movieDetailViewModelWithData()
        )
    }
}
