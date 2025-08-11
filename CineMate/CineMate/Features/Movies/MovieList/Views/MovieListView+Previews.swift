//
//  MovieListView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

@MainActor
extension MovieListView {
    static var previewWithMovies: some View {
        MovieListView(
            viewModel: PreviewFactory.movieListViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel(),
            castViewModel: PreviewFactory.castViewModel()
        )
    }
}
