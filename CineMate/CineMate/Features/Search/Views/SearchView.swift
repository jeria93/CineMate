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
                        viewModel.performSearch()
                    }

                List(viewModel.results) { movie in
                    Text(movie.title)
                }
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView.previewDefault
}
