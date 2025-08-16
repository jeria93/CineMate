//
//  FavoriteMoviesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// SwiftUI previews for the Favorites screen, showcasing all UI states
/// **without** starting Firebase/Firestore. Each preview injects a
/// preconfigured `FavoriteMoviesViewModel` from `PreviewFactory`.
///
/// States:
/// - `previewDefault`  → list with favorites (happy path)
/// - `previewEmpty`    → empty list (empty state)
/// - `previewLoading`  → loading spinner visible
/// - `previewError`    → error message with retry
///
/// Notes:
/// - No network calls in previews
/// - Deterministic data via `SharedPreviewMovies`
/// - Keeps the view code minimal; all state is provided by the factory
extension FavoriteMoviesView {

    /// Preview showing a populated favorites list.
    static var previewDefault: some View {
        FavoriteMoviesView(viewModel: PreviewFactory.favoritesViewModel())
    }

    /// Preview showing the empty state (no favorites).
    static var previewEmpty: some View {
        FavoriteMoviesView(viewModel: PreviewFactory.emptyFavoritesViewModel())
    }

    /// Preview showing the loading state.
    static var previewLoading: some View {
        FavoriteMoviesView(viewModel: PreviewFactory.loadingFavoritesViewModel())
    }

    /// Preview showing an error state with retry option.
    static var previewError: some View {
        FavoriteMoviesView(viewModel: PreviewFactory.errorFavoritesViewModel())
    }
}
