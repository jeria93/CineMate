//
//  MovieListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieViewModel
    @StateObject private var castViewModel: CastViewModel

    init(viewModel: MovieViewModel, castViewModel: CastViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _castViewModel = StateObject(wrappedValue: castViewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                MovieCategoryPicker(selectedCategory: $viewModel.selectedCategory)

                MovieListContentView(
                    viewModel: viewModel,
                    castViewModel: castViewModel
                )
            }
            .navigationTitle(viewModel.selectedCategory.displayName)
            .task {
                await viewModel.loadMovies()
            }
        }
    }
}

#Preview("MovieList Default") {
    MovieListView.previewWithMovies
}
