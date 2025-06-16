//
//  MovieListView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

#Preview("Default list") {
    MovieListView(repository: MockMovieRepository())
}

#Preview("Loading state") {
    let viewModel = MockMovieViewModel()
    viewModel.isLoading = true
    return MovieListContentView(viewModel: viewModel)
        .padding()
}

#Preview("Error state") {
    let viewModel = MockMovieViewModel()
    viewModel.errorMessage = "Oops! Something went wrong."
    return MovieListContentView(viewModel: viewModel)
        .padding()
}

#Preview("Empty list") {
    let viewModel = MockMovieViewModel()
    viewModel.movies = []
    return MovieListContentView(viewModel: viewModel)
        .padding()
}

#Preview("Dark Mode") {
    MovieListView(repository: MockMovieRepository())
        .preferredColorScheme(.dark)
}
