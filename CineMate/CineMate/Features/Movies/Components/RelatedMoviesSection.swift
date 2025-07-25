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

            if movies.isEmpty {
                HStack {
                    Image(systemName: "film")
                        .foregroundColor(.secondary)
                    Text("No recommendations available.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
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

#Preview("Single Movie") {
    RelatedMoviesSection.previewSingleMovie
}

#Preview("Many Movies") {
    RelatedMoviesSection.previewManyMovies
}
