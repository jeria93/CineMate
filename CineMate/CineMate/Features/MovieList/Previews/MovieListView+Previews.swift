//
//  MovieListView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import SwiftUI

extension MovieListView {
    static var preview: some View {
        MovieListView(
            viewModel: PreviewFactory.movieListViewModel,
            castViewModelProvider: { PreviewFactory.castViewModel }
        )
    }
}
