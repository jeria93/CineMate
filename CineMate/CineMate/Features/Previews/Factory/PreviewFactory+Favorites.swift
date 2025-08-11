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

    // MARK: - Core small builder

    /// Build an exact-state FavoriteMoviesViewModel.
    /// - Parameter movies: Movies that should appear as favorites.
    static func favoritesVM(with movies: [Movie]) -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = movies
        vm.isLoading = false
        vm.errorMessage = nil
        return vm
    }

    // MARK: - Ready-made scenarios

    /// Default: list with favorites (happy path).
    static func favoritesViewModel() -> FavoriteMoviesViewModel {
        SharedPreviewMovies.resetIDs()
        return favoritesVM(with: SharedPreviewMovies.moviesList)
    }

    /// Empty: no favorites yet.
    static func emptyFavoritesViewModel() -> FavoriteMoviesViewModel {
        favoritesVM(with: [])
    }

    /// Loading: spinner visible.
    static func loadingFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = favoritesVM(with: [])
        vm.isLoading = true
        return vm
    }

    /// Error: simulated failure (e.g., network issue).
    static func errorFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = favoritesVM(with: [])
        vm.errorMessage = "Network unreachable"
        return vm
    }
}
