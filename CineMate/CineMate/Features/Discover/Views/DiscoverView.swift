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
                await viewModel.fetchAllSections()
            }
            .refreshable {
                await viewModel.fetchAllSections()
            }
    }

    /// Conditionally renders the correct view based on the current state.
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView(title: "Loading…")
        } else if let err = viewModel.error {
            ErrorMessageView(
                title: "Something went wrong",
                message: err.localizedDescription
            )
        } else if viewModel.allSectionsAreEmpty {
            EmptyStateView(
                systemImage: "film",
                title: "No movies to show.",
                message: "There’s no content here at the moment."
            )
        } else {
            DiscoverContentView(viewModel: viewModel)
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
