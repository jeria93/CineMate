//
//  MovieListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieViewModel

    init(repository: MovieProtocol = MovieRepository()) {
        _viewModel = StateObject(wrappedValue: MovieViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading movies...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.fetchPopularMovies() }
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
            .navigationTitle("Popular Movies")
            .task {
                await viewModel.fetchPopularMovies()
            }
        }
    }
}

#Preview {
    MovieListView()
}
