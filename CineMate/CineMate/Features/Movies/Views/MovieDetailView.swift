//
//  MovieDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-09.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject var movieViewModel: MovieViewModel
    @ObservedObject var castViewModel: CastViewModel
    @ObservedObject var favoriteViewModel: FavoriteMoviesViewModel

    private var movie: Movie? { movieViewModel.movie(by: movieId) }

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
                            MovieFavoriteButtonView(movie: movie, favoriteViewModel: favoriteViewModel)
                        }

                        MovieDetailInfoView(movie: movie, viewModel: movieViewModel)
                        MovieDetailActionBarView(movie: movie)
                    } else if movieViewModel.isLoadingDetail {
                        LoadingView(title: "Loading movie…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 80)
                    } else {
                        ErrorMessageView(
                            title: "Failed to load movie",
                            message: "Something went wrong or no data was found.",
                            onRetry: {
                                Task { await movieViewModel.loadMovieDetails(for: movieId) }
                            }
                        )
                        .padding(.top, 80)
                    }

                    if let credits = movieViewModel.movieCredits {
                        CreditsSection(credits: credits)
                    }

                    if let recs = movieViewModel.recommendedMovies, !recs.isEmpty {
                        RelatedMoviesSection(
                            movies: recs,
                            movieViewModel: movieViewModel,
                            castViewModel: castViewModel
                        )
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                proxy.scrollTo("TOP", anchor: .top)
                print("[MovieDetailView] appeared for id:", movieId)
            }
            .onChange(of: movieId) { proxy.scrollTo("TOP", anchor: .top) }
        }
        .task(id: movieId) {
            await movieViewModel.loadMovieDetails(for: movieId)
        }
        .navigationTitle(movie?.title ?? "Loading…")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if movieViewModel.isLoadingDetail && movie != nil {
                LoadingView(title: "Loading details…")
                    .scaleEffect(1.2)
            }
        }
    }
}

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
