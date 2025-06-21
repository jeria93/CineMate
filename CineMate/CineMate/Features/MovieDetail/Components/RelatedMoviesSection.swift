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
        }
    }
}

#Preview("With Movies") {
    let mockRepo = MockMovieRepository()
    let viewModel = MovieViewModel(repository: mockRepo)

    return RelatedMoviesSection(
        movies: PreviewData.moviesList,
        movieViewModel: viewModel,
        castViewModelProvider: { CastViewModel(repository: mockRepo) }
    )
    .padding()
    .background(Color(.systemBackground))
    .border(.gray.opacity(0.3))
}

#Preview("Empty State") {
    let mockRepo = MockMovieRepository()
    let viewModel = MovieViewModel(repository: mockRepo)

    return RelatedMoviesSection(
        movies: [],
        movieViewModel: viewModel,
        castViewModelProvider: { CastViewModel(repository: mockRepo) }
    )
    .padding()
    .background(Color(.systemBackground))
    .border(.gray.opacity(0.3))
}
