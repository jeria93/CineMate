//
//  MovieListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI


struct MovieListView: View {
    @StateObject private var viewModel: MovieViewModel
    private let castViewModelProvider: () -> CastViewModel

    init(
        viewModel: MovieViewModel,
        castViewModelProvider: @escaping () -> CastViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.castViewModelProvider = castViewModelProvider
    }

    var body: some View {
        NavigationStack {
            VStack {
                MovieCategoryPicker(selectedCategory: $viewModel.selectedCategory)

                MovieListContentView(
                    viewModel: viewModel,
                    castViewModelProvider: castViewModelProvider
                )
            }
            .navigationTitle(viewModel.selectedCategory.displayName)
            .task {
                await viewModel.loadMovies()
            }
        }
    }
}

#Preview("MovieListView") {
    MovieListView(viewModel: PreviewFactory.movieListViewModel) {
        PreviewFactory.castViewModel
    }
}
