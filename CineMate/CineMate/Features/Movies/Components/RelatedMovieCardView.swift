//
//  RelatedMovieCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMovieCardView: View {
    let movie: Movie
    let movieViewModel: MovieViewModel?

    @EnvironmentObject private var navigator: AppNavigator

    init(movie: Movie, movieViewModel: MovieViewModel? = nil) {
        self.movie = movie
        self.movieViewModel = movieViewModel
    }

    var body: some View {
        Button {
            movieViewModel?.cacheStub(movie)
            navigator.goToMovie(id: movie.id)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                PosterImageView(
                    url: movie.posterSmallURL,
                    title: movie.title,
                    width: 100,
                    height: 150
                )

                Text(movie.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
            .frame(width: 100, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RelatedMovieCardView.preview.withPreviewNavigation()
}
