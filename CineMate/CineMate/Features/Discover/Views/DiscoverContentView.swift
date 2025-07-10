//
//  DiscoverContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

struct DiscoverContentView: View {
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        if viewModel.isLoading {
            LoadingView(text: "Loading movies...")
        } else if let error = viewModel.error {
            ErrorMessageView(message: error.localizedDescription)
        } else if viewModel.results.isEmpty {
            EmptyResultsView(query: "No results found")
        } else {
            SearchResultsList(movies: viewModel.results)
        }
    }
}

#Preview("Default") {
    DiscoverContentView.previewDefault
}

#Preview("Loading") {
    DiscoverContentView.previewLoading
}

#Preview("Empty") {
    DiscoverContentView.previewEmpty
}

#Preview("Error") {
    DiscoverContentView.previewError
}
