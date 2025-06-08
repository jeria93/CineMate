//
//  MovieListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieViewModel
    @State private var selectedCategory: MovieCategory = .popular

    init(repository: MovieProtocol = MovieRepository()) {
        _viewModel = StateObject(wrappedValue: MovieViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack {
                MovieCategoryPicker(selectedCategory: $viewModel.selectedCategory)
                MovieListContentView(viewModel: viewModel)
            }
            .navigationTitle(selectedCategory.displayName)
            .task {
                await viewModel.loadMovies()
            }
        }
    }
}

#Preview {
    MovieListView()
}
