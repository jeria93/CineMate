//
//  DiscoverView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel: DiscoverViewModel

    init(viewModel: DiscoverViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(title: "Loading...")
                } else if let error = viewModel.error {
                    ErrorMessageView(
                        title: "Something went wrong",
                        message: error.localizedDescription
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
                guard !ProcessInfo.processInfo.isPreview else { return }
                try? await Task.sleep(nanoseconds: 300_000_000) // Delay i sim
                await viewModel.fetchAllSections()
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
