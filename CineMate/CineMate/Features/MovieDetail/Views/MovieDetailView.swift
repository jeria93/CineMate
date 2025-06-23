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
    @StateObject var castViewModel: CastViewModel

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
        .task {
            await viewModel.loadMovieCredits(for: movie.id)
            await viewModel.loadMovieVideos(for: movie.id)
            await viewModel.fetchRecommendedMovies(for: movie.id)
            await viewModel.loadMovieDetails(for: movie.id)
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Star Wars Detail") {
    MovieDetailView.previewInstance()
}

extension MovieDetailView {
    static func previewInstance() -> some View {
        let repo = MockMovieRepository()
        let movieVM = MovieViewModel(repository: repo)
        movieVM.movieCredits = PreviewData.starWarsCredits
        movieVM.movieDetail = PreviewData.starWarsDetail
        let castVM = CastViewModel(repository: repo)

        return MovieDetailView(
            movie: PreviewData.starWars,
            viewModel: movieVM,
            castViewModel: castVM
        )
    }
}
