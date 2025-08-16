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
    let castViewModel: CastViewModel
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        VStack {
            MovieCategoryPicker(selectedCategory: $viewModel.selectedCategory)

            MovieListContentView(
                viewModel: viewModel,
                castViewModel: castViewModel,
                favoriteViewModel: favoriteViewModel
            )
        }
        .navigationTitle(viewModel.selectedCategory.displayName)
        .task(id: viewModel.selectedCategory) { await viewModel.loadMovies() }
        .refreshable { await viewModel.loadMovies() }
    }
}

#Preview("MovieList - Default") {
    MovieListView.previewWithMovies.withPreviewNavigation()
}
