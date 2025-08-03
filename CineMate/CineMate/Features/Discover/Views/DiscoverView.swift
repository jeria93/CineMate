//
//  DiscoverView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        Group {
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
        .navigationTitle("Discover")
        .task {
            await viewModel.fetchAllSections()
        }
        .refreshable {
            await viewModel.fetchAllSections()
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
