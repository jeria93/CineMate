//
//  DiscoverView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Main Discover screen.
/// - Shows loading, error, empty state or movie sections depending on state.
/// - Supports pull-to-refresh and async data fetching.
struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        content
            .navigationTitle("Discover")
            .task {
                await viewModel.refreshCurrentSelection()
            }
            .refreshable {
                await viewModel.refreshCurrentSelection(forceReload: true)
            }
    }

    /// Conditionally renders the correct view based on the current state.
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.allSectionsAreEmpty {
            LoadingView(title: "Loading…")
        } else if let err = viewModel.error, viewModel.allSectionsAreEmpty {
            ErrorMessageView(
                title: "Something went wrong",
                message: err.localizedDescription,
                onRetry: { Task { await viewModel.refreshCurrentSelection(forceReload: true) } }
            )
        } else if viewModel.allSectionsAreEmpty {
            EmptyStateView(
                systemImage: "film",
                title: "No movies to show.",
                message: "There’s no content here at the moment."
            )
        } else {
            DiscoverContentView(viewModel: viewModel)
                .overlay(alignment: .top) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(10)
                            .background(.thinMaterial, in: Capsule())
                            .padding(.top, 8)
                    }
                }
                .overlay(alignment: .bottom) {
                    if let err = viewModel.error, !viewModel.isLoading {
                        Text(err.localizedDescription)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 12)
                    }
                }
        }
    }
}

#Preview("Default") {
    DiscoverView.previewDefault
}

#Preview("Loading") {
    DiscoverView.previewLoading
}

#Preview("Empty") {
    DiscoverView.previewEmpty
}

#Preview("Error") {
    DiscoverView.previewError
}

#Preview("One Section") {
    DiscoverView.previewOneSection
}
