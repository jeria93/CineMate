//
//  MovieDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-09.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject var viewModel: MovieViewModel
    @ObservedObject var castViewModel: CastViewModel

    private var movie: Movie? { viewModel.movie(by: movieId) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Color.clear.frame(height: 1).id("TOP")

                    if let movie {
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

                        MovieDetailInfoView(movie: movie, viewModel: viewModel)
                        MovieDetailActionBarView(movie: movie)
                    } else if viewModel.isLoadingDetail {
                        LoadingView(title: "Loading movie…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 80)
                    } else {
                        ErrorMessageView(
                            title: "Failed to load movie",
                            message: "Something went wrong or no data was found.",
                            onRetry: {
                                Task { await viewModel.loadMovieDetails(for: movieId) }
                            }
                        )
                        .padding(.top, 80)
                    }

                    if let credits = viewModel.movieCredits {
                        CreditsSection(credits: credits)
                    }

                    if let recs = viewModel.recommendedMovies, !recs.isEmpty {
                        RelatedMoviesSection(
                            movies: recs,
                            movieViewModel: viewModel,
                            castViewModel: castViewModel
                        )
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                proxy.scrollTo("TOP", anchor: .top)
                print("[MovieDetailView] appeared for id:", movieId)
            }
            .onChange(of: movieId) { proxy.scrollTo("TOP", anchor: .top) }
        }
        .task(id: movieId) {
            await viewModel.loadMovieDetails(for: movieId)
        }
        .navigationTitle(movie?.title ?? "Loading…")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoadingDetail && movie != nil {
                LoadingView(title: "Loading details…")
                    .scaleEffect(1.2)
            }
        }
    }
}

// Reuse existing small component
private struct CreditsSection: View {
    let credits: MovieCredits

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MovieCreditsView(credits: credits)

            if let director = credits.crew.first(where: { $0.job == "Director" }) {
                DirectorView(director: director)
            }

            CastCarouselView(cast: credits.cast)
        }
    }
}

#Preview("Star Wars Detail") {
    MovieDetailView.previewDefault.withPreviewNavigation()
}
