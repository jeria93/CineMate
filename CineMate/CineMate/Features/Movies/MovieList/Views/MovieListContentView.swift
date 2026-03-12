//
//  MovieListContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieListContentView: View {
    @ObservedObject var viewModel: MovieViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    var body: some View {
        content
            .listStyle(.plain)
            .refreshable {
                await viewModel.loadMovies(page: 1)
            }
    }
}

private extension MovieListContentView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading, viewModel.movies.isEmpty {
            LoadingView(title: "Loading movies...")

        } else if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
            ErrorMessageView(title: "Failed", message: error) {
                Task { await viewModel.loadMovies(page: 1) }
            }

        } else if viewModel.movies.isEmpty {
            EmptyStateView(
                systemImage: "film",
                title: "No movies yet",
                message: "Try another category or pull to refresh.",
                actionTitle: "Reload",
                onAction: { Task { await viewModel.loadMovies(page: 1) } }
            )

        } else {
            List(viewModel.movies) { movie in
                MovieRowView(
                    movie: movie,
                    favoriteViewModel: favoriteViewModel
                )
                .contentShape(Rectangle())
                .task {
                    if viewModel.movies.last?.id == movie.id {
                        await viewModel.loadNextPageIfNeeded(currentItem: movie)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview("List Preview") {
    MovieListContentView.previewList
}

#Preview("Loading Preview") {
    MovieListContentView.previewLoading
}

#Preview("Error Preview") {
    MovieListContentView.previewError
}
