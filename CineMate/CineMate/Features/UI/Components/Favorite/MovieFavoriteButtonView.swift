//
//  MovieFavoriteButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct MovieFavoriteButtonView: View {
    let movie: Movie
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel


    private var isFavorite: Bool {
        favoriteViewModel.favoriteMovies.contains { $0.id == movie.id }
    }

    var body: some View {
        HeartButton(isOn: isFavorite) {
            Task { await favoriteViewModel.toggleFavorite(movie: movie) }
        }
    }

}

struct HeartButton: View {
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(isOn ? .red : .gray)
                .font(.title2)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MovieFavoriteButtonView.preview
}
