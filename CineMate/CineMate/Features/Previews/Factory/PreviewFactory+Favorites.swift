//
//  PreviewFactory+Favorites.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

extension PreviewFactory {

    /// A default favorite movies view model with 3 mock movies
    @MainActor
    static func favoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = [
            PreviewData.starWars,
            PreviewData.inception,
            PreviewData.matrix
        ]
        return vm
    }

    /// An empty favorite movies view model for testing empty states
    @MainActor
    static func emptyFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = []
        return vm
    }

    /// A loading state mock if you add isLoading in the future
    @MainActor
    static func loadingFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        // Simulate loading state here in the future if needed
        return vm
    }

    /// An error state mock if you add errorMessage in the future
    @MainActor
    static func errorFavoriteMoviesViewModel() -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        // Simulate error state here in the future if needed
        return vm
    }
}
