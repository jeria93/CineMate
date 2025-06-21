//
//  MovieListView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

extension MovieListView {
    static func previewInstance() -> some View {
        let repo = MockMovieRepository()
        let vm = MovieViewModel(repository: repo)
        vm.movies = PreviewData.moviesList

        return MovieListView(
            viewModel: vm,
            castViewModelProvider: { CastViewModel(repository: repo) }
        )
    }
}

#Preview("MovieListView Preview") {
    MovieListView.previewInstance()
}
