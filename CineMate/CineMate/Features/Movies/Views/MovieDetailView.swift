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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Color.clear.frame(height: 1).id("TOP")

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
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    MovieDetailInfoView(movie: movie, viewModel: viewModel)

                    if let credits = viewModel.movieCredits {
                        MovieCreditsView(credits: credits)

                        if let director = credits.crew.first(where: { $0.job == "Director" }) {
                            DirectorView(director: director)
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
            .onAppear {
                proxy.scrollTo("TOP", anchor: .top)
            }
            .onChange(of: movie.id) {
                proxy.scrollTo("TOP", anchor: .top)
            }
        }
        .task { await loadData() }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Star Wars Detail") {
    MovieDetailView.previewDefault.withPreviewNavigation()
}

private extension MovieDetailView {
    func loadData() async {
        await viewModel.loadMovieDetails(for: movie.id)
    }
}
