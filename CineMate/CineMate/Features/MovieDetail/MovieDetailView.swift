//
//  MovieDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-09.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        ScrollView {
            PosterImageView(
                url: movie.posterLargeURL,
                title: movie.title,
                width: 300,
                height: 450
            )
            .overlay(alignment: .topTrailing) {
                FavoriteButton(
                    isFavorite: viewModel.isFavorite(movie),
                    toggleAction: { viewModel.toggleFavorite(for: movie) }
                )
            }

            VStack(alignment: .leading, spacing: 16) {
                MovieDetailInfoView(movie: movie)

                if let credits = viewModel.movieCredits {
                    MovieCreditsView(credits: credits)
                }
            }
            .padding(.horizontal)

            RelatedMoviesSection(movies: viewModel.relatedMovies(for: movie))

            ShareButtonView(movie: movie)
                .padding(.top, 16)
                .padding(.horizontal)

            TMDBLinkButtonView(movie: movie)
                .padding(.horizontal)

            TrailerButtonView(movie: movie)
        }
        .task {
            await viewModel.loadMovieCredits(for: movie.id)
            await viewModel.loadMovieVideos(for: movie.id)
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MovieDetailView(
        movie: PreviewData.starWars,
        viewModel: MovieViewModel(repository: MockMovieRepository())
    )
}
