//
//  MovieFavoriteButtonView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieFavoriteButtonView {
    /// Preview showing the button in ON and OFF states using PreviewFactory
    static var preview: some View {
        SharedPreviewMovies.resetIDs()

        let favoriteMovie     = SharedPreviewMovies.inception
        let nonFavoriteMovie  = SharedPreviewMovies.interstellar

        let vmOn  = PreviewFactory.favoritesVM(with: [favoriteMovie])
        let vmOff = PreviewFactory.favoritesVM(with: [])

        return VStack(spacing: 20) {
            MovieFavoriteButtonView(movie: favoriteMovie,     favoriteViewModel: vmOn)   // ON
            MovieFavoriteButtonView(movie: nonFavoriteMovie,  favoriteViewModel: vmOff)  // OFF
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
