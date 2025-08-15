//
//  PreviewFactory+Favorites.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Factory helpers for building `FavoriteMoviesViewModel` preview states.
/// Purely static – zero Firebase/Auth calls for fast, reliable previews.
@MainActor
extension PreviewFactory {

    /// Core builder that delegates to the VM's static preview initializer.
    /// - Parameter movies: Movies to expose in the UI.
    static func favoritesVM(with movies: [Movie]) -> FavoriteMoviesViewModel {
        .preview(with: movies)
    }

    /// Default scenario: a reasonable list of favorites.
    static func favoritesViewModel() -> FavoriteMoviesViewModel {
        SharedPreviewMovies.resetIDs()
        return favoritesVM(with: SharedPreviewMovies.moviesList)
    }

    /// Empty scenario: no favorites yet.
    static func emptyFavoritesViewModel() -> FavoriteMoviesViewModel {
        favoritesVM(with: [])
    }

    /// Many scenario: stress test layout/scrolling.
    static func manyFavoritesViewModel() -> FavoriteMoviesViewModel {
        SharedPreviewMovies.resetIDs()
        let many = (1...20).map { i in
            Movie(
                id: PreviewID.next(),
                title: "Sample \(i)",
                overview: nil,
                posterPath: nil,
                backdropPath: nil,
                releaseDate: nil,
                voteAverage: nil,
                genres: nil
            )
        }
        return favoritesVM(with: many)
    }

    /// Loading scenario: spinner visible.
    static func loadingFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = favoritesVM(with: [])
        vm.isLoading = true
        return vm
    }

    /// Error scenario: simulated failure message.
    static func errorFavoritesViewModel() -> FavoriteMoviesViewModel {
        let vm = favoritesVM(with: [])
        vm.errorMessage = "Network unreachable"
        return vm
    }
}
