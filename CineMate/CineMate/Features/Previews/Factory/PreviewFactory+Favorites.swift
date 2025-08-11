//
//  PreviewFactory+Favorites.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Creates preconfigured `FavoriteMoviesViewModel` instances for SwiftUI previews.
/// This mocks all UI states (Default/Empty/Loading/Error) **without** touching
/// Firebase Auth or Firestore — ideal for fast, reliable UI iteration.
///
/// Policy:
/// - No network calls in previews
/// - Explicitly set state (`favoriteMovies`, `isLoading`, `errorMessage`)
/// - Deterministic data via `SharedPreviewMovies` + `PreviewID.reset()`
@MainActor
extension PreviewFactory {

    /// Default: list with favorites (happy path).
    static func favoritesViewModel() -> FavoriteMoviesViewModel {
        PreviewID.reset()
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = SharedPreviewMovies.moviesList
        vm.isLoading = false
        vm.errorMessage = nil
        return vm
    }

    /// Empty: no favorites yet.
    static func emptyFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = []
        vm.isLoading = false
        vm.errorMessage = nil
        return vm
    }

    /// Loading: spinner visible.
    static func loadingFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = []
        vm.isLoading = true
        vm.errorMessage = nil
        return vm
    }

    /// Error: simulated failure (e.g., network issue).
    static func errorFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = []
        vm.isLoading = false
        vm.errorMessage = "Network unreachable"
        return vm
    }
}
