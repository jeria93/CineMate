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
        switch viewModel.contentState {
        case .loading:
            LoadingView(title: "Loading favorites...")

        case .error(let message):
            ErrorMessageView(
                title: "Failed to load favorites",
                message: message,
                onRetry: { viewModel.retryListener() }
            )

        case .empty:
            EmptyStateView(
                systemImage: "heart",
                title: "No favorites yet",
                message: "Tap the heart on a movie to add it to your favorites"
            )

        case .content:
            List {
                if let inlineError = viewModel.inlineErrorMessage {
                    Text(inlineError)
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                }

                ForEach(viewModel.favoriteMovies) { movie in
                    MovieRowView(
                        movie: movie,
                        favoriteViewModel: viewModel
                    )
                }
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
