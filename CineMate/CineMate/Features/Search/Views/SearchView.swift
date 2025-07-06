//
//  SearchView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView(text: $viewModel.query) {
                    Task { await viewModel.search() }
                }

                if viewModel.isLoading {
                    LoadingView(text: "Searching movies...")
                } else if let error = viewModel.errorMessage {
                    ErrorMessageView(message: error)
                } else if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                    EmptyResultsView()
                } else {
                    SearchResultsList(movies: viewModel.results)
                }
            }
            .navigationTitle("Search")
        }
    }
}

#Preview("Default") {
    SearchView.previewDefault
}

#Preview("Loading") {
    SearchView.previewLoading
}

#Preview("Error") {
    SearchView.previewError
}

#Preview("Empty") {
    SearchView.previewEmpty
}
