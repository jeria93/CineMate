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
    @ObservedObject var castViewModel: CastViewModel

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
                                castViewModel: castViewModel
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
