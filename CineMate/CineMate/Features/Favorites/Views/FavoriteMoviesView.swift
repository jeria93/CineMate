//
//  FavoriteMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct FavoriteMoviesView: View {
    @ObservedObject var viewModel: FavoriteMoviesViewModel

    var body: some View {
        List(viewModel.favoriteMovies) { movie in
            MovieRowView(
                movie: movie,
                isFavorite: true,
                onToggleFavorite: { Task { await viewModel.toggleFavorite(movie: movie) } }
            )
        }
        .navigationTitle("Favorites")
        .task { await viewModel.startFavoritesListener() }
        .onDisappear { viewModel.stopFavoritesListener() }
    }
}

#Preview {
    FavoriteMoviesView.previewDefault
}
