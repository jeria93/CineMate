//
//  SeeAllMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct SeeAllMoviesView: View {
    @ObservedObject var viewModel: SeeAllMoviesViewModel
    let title: String

    var body: some View {
        ScrollView {
            MovieGridView(movies: viewModel.movies) {
                Task { await viewModel.fetchMoreMovies() }
            }
            .padding()
        }
        .navigationTitle(title)
        .task(id: title) {
            if !ProcessInfo.processInfo.isPreview {
                viewModel.clearCache()
                await viewModel.loadInitialMovies()
            }
        }
        .overlay {
            Group {
                if viewModel.isLoading {
                    LoadingView(title: "Loading movies...")
                } else if viewModel.hasError {
                    ErrorMessageView(
                        title: "Oops!",
                        message: viewModel.errorMessage ?? "Unknown error",
                        onRetry: {
                            Task { await viewModel.fetchMoreMovies() }
                        }
                    )
                } else if viewModel.movies.isEmpty {
                    EmptyStateView(
                        systemImage: "film",
                        title: "No Movies Found",
                        message: "Try changing filters or come back later."
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.25))
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
