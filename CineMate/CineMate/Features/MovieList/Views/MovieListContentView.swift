//
//  MovieListContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieListContentView: View {
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading movies...")
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.loadMovies() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
   MovieListContentView(viewModel: MockMovieViewModel())
}
