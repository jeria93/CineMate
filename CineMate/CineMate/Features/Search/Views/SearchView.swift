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
    var isGuestMode: Bool = false

    var body: some View {
        VStack {
            SearchBarView(
                text: $searchViewModel.query,
                isDisabled: isGuestMode
            )
            .onSubmit {
                Task { await searchViewModel.search(searchViewModel.query) }
            }

            if let message = searchViewModel.validationMessage {
                ValidationMessageView(message: message)
            }

            contentView
        }
        .navigationTitle("Search")
        .onAppear {
            searchViewModel.configureGuestMode(isGuest: isGuestMode)
        }
        .onChange(of: isGuestMode) { _, isGuest in
            searchViewModel.configureGuestMode(isGuest: isGuest)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch searchViewModel.state {
        case .prompt:
            SearchPromptView()
        case .loading:
            LoadingView(title: "Searching movies...")
        case .validationError:
            SearchPromptView()
        case .networkError:
            ErrorMessageView(
                title: "Search failed",
                message: searchViewModel.error?.localizedDescription ?? "Try again.",
                onRetry: { Task { await searchViewModel.retryLastSearch() } }
            )
        case .empty:
            EmptyResultsView(query: searchViewModel.trimmedQuery)
        case .results:
            SearchResultsList(
                movies: searchViewModel.results,
                favoriteViewModel: favoriteViewModel,
                isLoadingNextPage: searchViewModel.isLoadingNextPage,
                loadMoreAction: { movie in
                    Task { await searchViewModel.loadNextPageIfNeeded(currentItem: movie) }
                }
            )
        }
    }
}

#if DEBUG
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
#endif
