//
//  MovieListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieListView: View {
    @ObservedObject var viewModel: MovieViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    var body: some View {
        VStack {
            MovieCategoryPicker(selectedCategory: $viewModel.selectedCategory)

            MovieListContentView(
                viewModel: viewModel,
                favoriteViewModel: favoriteViewModel
            )
        }
        .navigationTitle(viewModel.selectedCategory.displayName)
        .task(id: viewModel.selectedCategory) {
            await viewModel.loadMovies(page: 1)
        }
    }
}

#Preview("MovieList - Default") {
    MovieListView.previewWithMovies.withPreviewNavigation()
}
