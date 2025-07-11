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
                
                if viewModel.query.isEmpty {
                    SearchPromptView()
                } else if viewModel.isLoading {
                    LoadingView(title: "Searching movies...")
                } else if let error = viewModel.error {
                    ErrorMessageView(title: "Error", message: error.localizedDescription)
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

#Preview("Prompt") {
    SearchView.previewPrompt
}

#Preview("With Results") {
    SearchView.previewDefault
}

#Preview("Empty State") {
    SearchView.previewEmpty
}

#Preview("Loading") {
    SearchView.previewLoading
}

#Preview("Error") {
    SearchView.previewError
}

#Preview("Validation Error") {
    SearchView.previewValidation
}
