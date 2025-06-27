//
//  MovieDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-09.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @StateObject private var viewModel: MovieViewModel
    @StateObject private var castViewModel: CastViewModel

    init(movie: Movie, viewModel: MovieViewModel, castViewModel: CastViewModel) {
        self.movie = movie
        _viewModel = StateObject(wrappedValue: viewModel)
        _castViewModel = StateObject(wrappedValue: castViewModel)
    }

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
                    CastCarouselView(cast: credits.cast, repository: viewModel.repository)
                }

                MovieDetailActionBarView(movie: movie)

                if let recommended = viewModel.recommendedMovies {
                    RelatedMoviesSection(
                        movies: recommended,
                        movieViewModel: viewModel,
                        castViewModelProvider: {
                            CastViewModel(repository: viewModel.repository)
                        }
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
    MovieDetailView.previewStarWars
}

private extension MovieDetailView {
    private func loadData() async {
        await viewModel.loadMovieCredits(for: movie.id)
        await viewModel.loadMovieVideos(for: movie.id)
        await viewModel.fetchRecommendedMovies(for: movie.id)
        await viewModel.loadMovieDetails(for: movie.id)
    }
}
