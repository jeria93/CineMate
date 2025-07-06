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
                TextField("Search movies...", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        Task { await viewModel.search() }
                    }

                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                    Text("No results found")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(viewModel.results) { movie in
                        Text(movie.title)
                    }
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
