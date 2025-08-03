//
//  SeeAllMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct SeeAllMoviesView: View {
    @StateObject var viewModel: SeeAllMoviesViewModel
    let title: String

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                LoadingView(title: "Loading movies...")

            } else if viewModel.hasError && viewModel.movies.isEmpty {
                ErrorMessageView(
                    title: "Oops!",
                    message: viewModel.errorMessage ?? "Unknown error",
                    onRetry: {
                        Task { await viewModel.fetchMoreMovies() }
                    }
                )

            } else if !viewModel.isLoading && viewModel.movies.isEmpty {
                EmptyStateView(
                    systemImage: "film",
                    title: "No Movies Found",
                    message: "Try changing filters or come back later."
                )

            } else {
                ScrollView {
                    MovieGridView(movies: viewModel.movies) {
                        Task { await viewModel.fetchMoreMovies() }
                    }
                    .padding()

                    if viewModel.isLoading && !viewModel.movies.isEmpty {
                        LoadingView(title: "Loading more movies...")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle(title)
        .refreshable {
            viewModel.clearCache()
            await viewModel.loadInitialMovies()
        }
        .task {
            if viewModel.movies.isEmpty {
                await viewModel.loadInitialMovies()
            }
        }
    }
}

#Preview("Default") {
    SeeAllMoviesView.previewDefault.withPreviewNavigation()
}

#Preview("Empty") {
    SeeAllMoviesView.previewEmpty.withPreviewNavigation()
}

#Preview("Loading") {
    SeeAllMoviesView.previewLoading.withPreviewNavigation()
}

#Preview("Error") {
    SeeAllMoviesView.previewError.withPreviewNavigation()
}
