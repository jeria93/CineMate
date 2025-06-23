//
//  RelatedMoviesSection.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMoviesSection: View {
    let movies: [Movie]
    let movieViewModel: MovieViewModel
    let castViewModelProvider: () -> CastViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("You might also like")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(movies) { movie in
                        NavigationLink {
                            MovieDetailView(
                                movie: movie,
                                viewModel: movieViewModel,
                                castViewModel: castViewModelProvider()
                            )
                        } label: {
                            RelatedMovieCardView(movie: movie)
                        }
                    }
                }
                .padding(.horizontal)
            }

            if movies.isEmpty {
                Text("No recommendations available.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview("With Mock Movies") {
    RelatedMoviesSection.previewWithMovies
}

#Preview("Empty State") {
    RelatedMoviesSection.previewEmpty
}

extension RelatedMoviesSection {
    static var previewWithMovies: some View {
        let mockRepo = MockMovieRepository()
        let viewModel = MovieViewModel(repository: mockRepo)
        viewModel.recommendedMovies = PreviewData.moviesList

        return RelatedMoviesSection(
            movies: PreviewData.moviesList,
            movieViewModel: viewModel,
            castViewModelProvider: { CastViewModel(repository: mockRepo) }
        )
        .padding()
        .background(Color(.systemBackground))
    }

    static var previewEmpty: some View {
        let mockRepo = MockMovieRepository()
        let viewModel = MovieViewModel(repository: mockRepo)

        return RelatedMoviesSection(
            movies: [],
            movieViewModel: viewModel,
            castViewModelProvider: { CastViewModel(repository: mockRepo) }
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
