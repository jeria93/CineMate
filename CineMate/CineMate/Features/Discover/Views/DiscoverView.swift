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
            VStack {
                DiscoverSortMenu(selectedSort: $viewModel.filters.sortOption)
                DiscoverContentView(viewModel: viewModel)
            }
            .navigationTitle("Discover")
            .onChange(of: viewModel.filters) {
                Task { await viewModel.fetchDiscoverMovies() }
            }
            .task {
                await viewModel.fetchDiscoverMovies()
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
