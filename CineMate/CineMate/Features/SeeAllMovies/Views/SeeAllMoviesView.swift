//
//  SeeAllMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct SeeAllMoviesView: View {
    @StateObject private var viewModel: SeeAllMoviesViewModel
    let title: String

    init(title: String, viewModel: SeeAllMoviesViewModel) {
        self.title = title
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            MovieGridView(movies: viewModel.movies) {
                Task { await viewModel.fetchMoreMovies() }
            }

            if viewModel.isLoading {
                LoadingView(title: "Loading movies...")
            }
        }
        .padding()
        .navigationTitle(title)
        .task {
            if !ProcessInfo.processInfo.isPreview {
                await viewModel.loadInitialMovies()
            }
        }
        .overlay {
            if viewModel.hasError {
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
            }
        }
    }
}

#Preview("Default") {
    SeeAllMoviesView.previewDefault
}

#Preview("Empty") {
    SeeAllMoviesView.previewEmpty
}

#Preview("Loading") {
    SeeAllMoviesView.previewLoading
}

#Preview("Error") {
    SeeAllMoviesView.previewError
}
