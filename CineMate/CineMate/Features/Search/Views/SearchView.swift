//
//  SearchView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    var body: some View {
        VStack {
            SearchBarView(text: $searchViewModel.query)
                .onSubmit {
                    Task { await searchViewModel.search(searchViewModel.query) }
                }

            if let message = searchViewModel.validationMessage {
                ValidationMessageView(message: message)
            }

            contentView
        }
        .navigationTitle("Search")
    }

    @ViewBuilder
    private var contentView: some View {
        if searchViewModel.query.isEmpty {
            SearchPromptView()
        } else if searchViewModel.isLoading {
            LoadingView(title: "Searching movies...")
        } else if let error = searchViewModel.error {
            ErrorMessageView(
                title: "Error",
                message: error.localizedDescription,
                onRetry: { Task { await searchViewModel.search(searchViewModel.query) } }
            )
        } else if searchViewModel.results.isEmpty && !searchViewModel.trimmedQuery.isEmpty {
            EmptyResultsView(query: searchViewModel.trimmedQuery)
        } else {
            SearchResultsList(
                movies: searchViewModel.results,
                favoriteIDs: Set(favoriteViewModel.favoriteMovies.map { $0.id }),
                onToggleFavorite: { movie in
                    Task { await favoriteViewModel.toggleFavorite(movie: movie) }
                },
                loadMoreAction: { movie in
                    Task { await searchViewModel.loadNextPageIfNeeded(currentItem: movie) }
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
