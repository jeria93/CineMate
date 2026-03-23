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
        MovieDetailView(
            movieId: SharedPreviewMovies.starWars.id,
            movieViewModel: PreviewFactory.movieListViewModel(),
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel(),
            detailViewModel: PreviewFactory.movieDetailViewModelWithData()
        )
    }

    @MainActor
    static var previewLoading: some View {
        MovieDetailView(
            movieId: PreviewID.scoped(.movieDetail, 901),
            movieViewModel: PreviewFactory.emptyMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.emptyFavoritesViewModel(),
            detailViewModel: PreviewFactory.movieDetailViewModelLoading()
        )
    }

    @MainActor
    static var previewError: some View {
        MovieDetailView(
            movieId: PreviewID.scoped(.movieDetail, 902),
            movieViewModel: PreviewFactory.emptyMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.emptyFavoritesViewModel(),
            detailViewModel: PreviewFactory.movieDetailViewModelError()
        )
    }

    @MainActor
    static var previewEmptyDetail: some View {
        let detailVM = PreviewFactory.movieDetailViewModelEmptyDetail()
        return MovieDetailView(
            movieId: detailVM.movieDetail?.id ?? PreviewID.scoped(.movieDetail, 900),
            movieViewModel: PreviewFactory.emptyMovieViewModel(),
            castViewModel: PreviewFactory.castViewModel(),
            favoriteViewModel: PreviewFactory.emptyFavoritesViewModel(),
            detailViewModel: detailVM
        )
    }
}
