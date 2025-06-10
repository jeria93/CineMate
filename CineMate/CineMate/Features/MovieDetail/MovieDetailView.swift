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
                Button {
                    viewModel.toggleFavorite(for: movie)
                } label: {
                    Image(systemName: viewModel.isFavorite(movie) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
                .padding()
            }

            MovieRowDetails(
                movie: movie,
                spacing: 16,
                titleFont: .largeTitle.bold(),
                overviewFont: .body,
                showFullOverview: true
            )
            .padding(.horizontal)
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
