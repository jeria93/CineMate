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

    @State private var isToggling = false

    private var isFavorite: Bool {
        favoriteViewModel.favoriteMovies.contains { $0.id == movie.id }
    }

    var body: some View {
        HeartButton(isOn: isFavorite, isDisabled: isToggling) {
            guard !isToggling else { return }
            isToggling = true

            Task {
                await favoriteViewModel.toggleFavorite(movie: movie)
                isToggling = false
            }
        }
    }
}

struct HeartButton: View {
    let isOn: Bool
    var isDisabled = false
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(isOn ? .red : .gray)
                .font(.title2)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
                .opacity(isDisabled ? 0.7 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    MovieFavoriteButtonView.preview
}
