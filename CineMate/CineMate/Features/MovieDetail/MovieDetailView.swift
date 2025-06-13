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

                if let recommended = viewModel.recommendedMovies {
                    RelatedMoviesSection(movies: recommended, viewModel: viewModel)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: recommended)
                }

                ShareButtonView(movie: movie)
                TMDBLinkButtonView(movie: movie)
                TrailerButtonView(movie: movie)
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadMovieCredits(for: movie.id)
            await viewModel.loadMovieVideos(for: movie.id)
            await viewModel.fetchRecommendedMovies(for: movie.id)
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
