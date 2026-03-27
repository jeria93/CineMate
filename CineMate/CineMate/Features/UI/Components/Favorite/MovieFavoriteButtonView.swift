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
        favoriteViewModel.isFavorite(id: movie.id)
    }

    private var isToggling: Bool {
        favoriteViewModel.isToggleInFlight(id: movie.id)
    }

    var body: some View {
        HeartButton(isOn: isFavorite, isDisabled: isToggling) {
            Task {
                await favoriteViewModel.toggleFavorite(movie: movie)
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
                .foregroundStyle(isOn ? Color.tmdbGreen : Color.appTextSecondary)
                .font(.title3.weight(.semibold))
                .padding(SharedUI.Spacing.small)
                .background(
                    Circle()
                        .fill(Color.appSurface.opacity(0.96))
                )
                .overlay(
                    Circle()
                        .stroke(Color.appTextSecondary.opacity(0.20), lineWidth: 1)
                )
                .opacity(isDisabled ? 0.7 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(isOn ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to update favorites")
    }
}

#Preview {
    MovieFavoriteButtonView.preview
}
