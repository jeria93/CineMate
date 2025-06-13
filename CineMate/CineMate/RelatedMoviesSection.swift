//
//  RelatedMoviesSection.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMoviesSection: View {
    let movies: [Movie]
    let viewModel: MovieViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            Text("Related Movies")
                .font(.headline)
                .padding(.horizontal)

            if movies.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)

                    Text("No recommendations for this title yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 150)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movies) { movie in
                            NavigationLink {
                                MovieDetailView(movie: movie, viewModel: MovieViewModel(repository: viewModel.repository))
                            } label: {
                                RelatedMovieCardView(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 16)
    }
}

#Preview("With Movies") {
    RelatedMoviesSection(movies: PreviewData.moviesList, viewModel: MockMovieViewModel())
        .padding()
        .background(Color(.systemBackground))
        .border(.gray.opacity(0.3))
}

#Preview("Empty State") {
    RelatedMoviesSection(movies: [], viewModel: MockMovieViewModel())
        .padding()
        .background(Color(.systemBackground))
        .border(.gray.opacity(0.3))
}
