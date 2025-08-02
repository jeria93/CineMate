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
        DiscoverContentView(viewModel: viewModel)
            .navigationTitle("Discover")
            .task {
                await viewModel.fetchAllSections()
            }
            .refreshable {
                await viewModel.fetchAllSections()
            }
            .overlay {
                Group {
                    if viewModel.isLoading {
                        LoadingView(title: "Loading…")
                    } else if let error = viewModel.error {
                        ErrorMessageView(
                            title: "Failed to Load",
                            message: error.localizedDescription,
                            onRetry: {
                                Task { await viewModel.fetchAllSections() }
                            }
                        )
                    } else if viewModel.allSectionsAreEmpty {
                        EmptyStateView(
                            systemImage: "film",
                            title: "No Movies",
                            message: "We couldn't find any movies for your filters"
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.25))
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
