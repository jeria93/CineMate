//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// ViewModel for the `FavoriteMoviesView`.
/// Handles loading mock favorite movies for previews or testing purposes.
@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    /// List of favorite movies shown in the view.
    @Published var favoriteMovies: [Movie] = []

    /// Initializes and loads mock data.
    init() {
        loadFavoriteMovies()
    }

    /// Loads a predefined list of mock favorite movies.
    /// Calls `PreviewID.reset()` before assigning to ensure unique IDs
    /// if any `PreviewID.next()` calls exist inside `SharedPreviewMovies`.
    private func loadFavoriteMovies() {
        PreviewID.reset()
        favoriteMovies = [
            SharedPreviewMovies.starWars,
            SharedPreviewMovies.inception,
            SharedPreviewMovies.matrix,
        ]
    }
}
