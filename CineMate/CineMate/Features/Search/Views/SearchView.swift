//
//  SearchView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    var body: some View {
        VStack {
            SearchBarView(text: $viewModel.query)

            if let message = viewModel.validationMessage {
                ValidationMessageView(message: message)
            }

            contentView
        }
        .navigationTitle("Search")
        .task { await favoriteViewModel.startFavoritesListenerIfNeeded() }
        .onDisappear { favoriteViewModel.stopFavoritesListenerIfNeeded() }
    }

    // MARK: - State-driven UI
    @ViewBuilder
    private var contentView: some View {
        if viewModel.query.isEmpty {
            SearchPromptView()
        } else if viewModel.isLoading {
            LoadingView(title: "Searching movies...")
        } else if let error = viewModel.error {
            ErrorMessageView(
                title: "Error",
                message: error.localizedDescription,
                onRetry: { Task { await viewModel.search(viewModel.query) } }
            )
        } else if viewModel.results.isEmpty && !viewModel.trimmedQuery.isEmpty {
            EmptyResultsView(query: viewModel.trimmedQuery)
        } else {
            SearchResultsList(
                movies: viewModel.results,
                favoriteIDs: Set(favoriteViewModel.favoriteMovies.map { $0.id }),
                onToggleFavorite: { movie in
                    Task { await favoriteViewModel.toggleFavorite(movie: movie) }
                },
                loadMoreAction: { movie in
                    Task { await viewModel.loadNextPageIfNeeded(currentItem: movie) }
                }
            )
        }
    }
}

#Preview("Prompt") {
    SearchView.previewPrompt.withPreviewNavigation()
}

#Preview("With Results") {
    SearchView.previewDefault.withPreviewNavigation()
}

#Preview("Empty State") {
    SearchView.previewEmpty.withPreviewNavigation()
}

#Preview("Loading") {
    SearchView.previewLoading.withPreviewNavigation()
}

#Preview("Error") {
    SearchView.previewError.withPreviewNavigation()
}

#Preview("Validation Error") {
    SearchView.previewValidation.withPreviewNavigation()
}
