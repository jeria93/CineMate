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
        contentView
            .navigationTitle("Favorites")
    }

    @ViewBuilder
    private var contentView: some View {
        if let message = viewModel.errorMessage {
            ErrorMessageView(title: "Failed to load", message: message)
        } else if viewModel.isLoading {
            LoadingView(title: "Loading favorites...")
        } else if viewModel.favoriteMovies.isEmpty {
            EmptyStateView(
                systemImage: "heart",
                title: "No favorites yet",
                message: "Tap the heart on a movie to add it to your favorites"
            )
        } else {
            List(viewModel.favoriteMovies) { movie in
                MovieRowView(
                    movie: movie,
                    isFavorite: true,
                    onToggleFavorite: {
                        Task { await viewModel.toggleFavorite(movie: movie) }
                    }
                )
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview("Default") { FavoriteMoviesView.previewDefault }
#Preview("Empty") { FavoriteMoviesView.previewEmpty }
#Preview("Loading") { FavoriteMoviesView.previewLoading }
#Preview("Error") { FavoriteMoviesView.previewError }
