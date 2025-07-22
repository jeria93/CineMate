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
    @ObservedObject var castViewModel: CastViewModel

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
                .padding()
            }

            VStack(alignment: .leading, spacing: 16) {
                MovieDetailInfoView(movie: movie, viewModel: viewModel)

                if let credits = viewModel.movieCredits {
                    MovieCreditsView(credits: credits)
                    if let director = credits.crew.first(where: { $0.job == "Director" }) {
                        DirectorView(director: director, repository: viewModel.repository)
                    }
                    CastCarouselView(cast: credits.cast, repository: viewModel.repository)
                }

                MovieDetailActionBarView(movie: movie)

                if let recommended = viewModel.recommendedMovies {
                    RelatedMoviesSection(
                        movies: recommended,
                        movieViewModel: viewModel,
                        castViewModel: castViewModel
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: recommended)
                }
            }
            .padding(.horizontal)
        }
        .task { await loadData() }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Star Wars Detail") {
    MovieDetailView.previewDefault
}

private extension MovieDetailView {
    private func loadData() async {
        await viewModel.loadMovieCredits(for: movie.id)
        await viewModel.loadMovieVideos(for: movie.id)
        await viewModel.fetchRecommendedMovies(for: movie.id)
        await viewModel.loadMovieDetails(for: movie.id)
        await viewModel.loadWatchProviders(for: movie.id)
    }
}
