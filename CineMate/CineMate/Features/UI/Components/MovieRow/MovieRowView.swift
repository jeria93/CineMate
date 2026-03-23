//
//  MovieRowView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        HStack(alignment: .top, spacing: SharedUI.Spacing.large) {
            rowTapTarget

            MovieFavoriteButtonView(movie: movie, favoriteViewModel: favoriteViewModel)
                .padding(.top, SharedUI.Spacing.xSmall)
        }
        .padding(.vertical, SharedUI.Spacing.small)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: SharedUI.Radius.medium, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var rowTapTarget: some View {
        HStack(alignment: .top, spacing: SharedUI.Spacing.large) {
            PosterImageView(
                url: movie.posterSmallURL,
                title: movie.title,
                width: SharedUI.Size.posterCompact.width,
                height: SharedUI.Size.posterCompact.height
            )

            MovieRowDetails(
                movie: movie,
                spacing: SharedUI.Spacing.small,
                titleFont: .headline,
                overviewFont: .subheadline,
                showFullOverview: false
            )

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            navigator.goToMovie(id: movie.id)
        }
    }
}
