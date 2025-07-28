//
//  FavoriteMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct FavoriteMoviesView: View {
    @StateObject private var viewModel: FavoriteMoviesViewModel
    
    init(viewModel: FavoriteMoviesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
            List(viewModel.favoriteMovies) { movies in
                MovieRowView(movie: movies)
                
            }
            .navigationTitle("Favorites")

    }
}

#Preview {
    FavoriteMoviesView.previewDefault
}
