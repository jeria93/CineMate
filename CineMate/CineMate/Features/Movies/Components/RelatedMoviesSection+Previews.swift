//
//  RelatedMoviesSection+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension RelatedMoviesSection {
    static var previewWithMovies: some View {
        RelatedMoviesSection(
            movies: PreviewFactory.recommendedMovies,
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    static var previewEmpty: some View {
        RelatedMoviesSection(
            movies: [],
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
