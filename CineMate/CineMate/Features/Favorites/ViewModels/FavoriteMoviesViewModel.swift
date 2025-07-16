//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    @Published var favoriteMovies: [Movie] = []

    init() {
        loadFavoriteMovies()
    }

    private func loadFavoriteMovies() {
        PreviewID.reset()
        favoriteMovies = [
            SharedPreviewMovies.starWars,
            SharedPreviewMovies.inception,
            SharedPreviewMovies.matrix,
        ]
    }
}
