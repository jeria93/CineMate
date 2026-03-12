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
        HStack(alignment: .top, spacing: 15) {
            rowTapTarget

            MovieFavoriteButtonView(movie: movie, favoriteViewModel: favoriteViewModel)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var rowTapTarget: some View {
        HStack(alignment: .top, spacing: 15) {
            PosterImageView(
                url: movie.posterSmallURL,
                title: movie.title,
                width: 80,
                height: 120
            )

            MovieRowDetails(
                movie: movie,
                spacing: 5,
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
