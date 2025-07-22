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
            switch (viewModel.isLoading, viewModel.errorMessage) {
            case (true, _):
                LoadingView(title: "Loading movies…")

            case (false, let error?):
                ErrorMessageView(title: "Failed", message: error) {
                    Task { await viewModel.loadMovies() }
                }

            default:
                List(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(movie) }
                }
                .listStyle(.plain)
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
