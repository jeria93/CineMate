//
//  PreviewFactory+Favorites.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Preview factory helpers for `FavoriteMoviesViewModel`.
///
/// Simulates various preview states (default, empty, loading, error) for UI testing.
/// These are injected into `FavoriteMoviesView` previews to avoid live Firestore or Auth.
extension PreviewFactory {

    /// A default state view model containing 3 mock favorite movies.
    ///
    /// `PreviewID.reset()` ensures ID uniqueness across previews.
    @MainActor
    static func favoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        PreviewID.reset()
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = [
            SharedPreviewMovies.starWars,
            SharedPreviewMovies.inception,
            SharedPreviewMovies.matrix
        ]
        return vm
    }

    /// An empty favorites list to simulate the no-data state.
    ///
    /// Useful for testing empty views, onboarding, or fallback UI.
    @MainActor
    static func emptyFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = []
        return vm
    }

    /// A simulated loading state.
    ///
    /// Can be customized later if `isLoading` is added to the view model.
    @MainActor
    static func loadingFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        // Simulate loading state here in the future if needed
        return vm
    }

    /// A simulated error state.
    ///
    /// Can be customized later if `errorMessage` or similar is added.
    @MainActor
    static func errorFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        // Simulate error state here in the future if needed
        return vm
    }
}
