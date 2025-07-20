//
//  MovieListContentView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

struct MovieListContentView: View {
    @ObservedObject var viewModel: MovieViewModel
    @ObservedObject var castViewModel: CastViewModel
    let onSelect: (Movie) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading movies...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                    Button("Retry") {
                        Task {
                            await viewModel.loadMovies()
                        }
                    }
                }
            } else {
                List(viewModel.movies) { movie in
                    NavigationLink {
                        MovieDetailView(
                            movie: movie,
                            viewModel: viewModel,
                            castViewModel: castViewModel
                        )
                    } label: {
                        MovieRowView(movie: movie)
                    }
                }
            }
        }
    }
}

#Preview("List Preview") {
    MovieListContentView.previewList
}

#Preview("Loading Preview") {
    MovieListContentView.previewLoading
}

#Preview("Error Preview") {
    MovieListContentView.previewError
}
