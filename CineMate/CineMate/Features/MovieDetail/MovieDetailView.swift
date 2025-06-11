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

            VStack(alignment: .leading, spacing: 16) {
                MovieDetailInfoView(movie: movie)

                if let credits = viewModel.movieCredits {
                    MovieCreditsView(credits: credits)
                }
            }
            .padding(.horizontal)

        }
        .task { await viewModel.loadMovieCredits(for: movie.id) }
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


struct MovieGenresView: View {
    let genres: [String]

    var body: some View {
        HStack {
            ForEach(genres, id: \.self) { genre in
                Text(genre)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}
