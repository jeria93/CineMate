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
                SearchBarView(text: $viewModel.query)

                if let message = viewModel.validationMessage {
                    ValidationMessageView(message: message)
                }

                if viewModel.isLoading {
                    LoadingView(text: "Searching movies...")
                } else if let error = viewModel.error {
                    ErrorMessageView(message: error.localizedDescription)
                } else if viewModel.results.isEmpty && !viewModel.trimmedQuery.isEmpty {
                    EmptyResultsView(query: viewModel.trimmedQuery)
                } else {
                    SearchResultsList(movies: viewModel.results)
                }
            }
            .navigationTitle("Search")
        }
    }
}

#Preview("With Results") {
    SearchView(viewModel: PreviewFactory.searchViewModel())
}

#Preview("Empty State") {
    SearchView(viewModel: PreviewFactory.emptySearchViewModel())
}

#Preview("Loading") {
    SearchView(viewModel: PreviewFactory.loadingSearchViewModel())
}

#Preview("Error") {
    SearchView(viewModel: PreviewFactory.errorSearchViewModel())
}

#Preview("Validation Error") {
    SearchView(viewModel: PreviewFactory.invalidSearchViewModel())
}
