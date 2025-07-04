//
//  RelatedMoviesSection+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension RelatedMoviesSection {

    /// Preview showing a typical list of recommended movies (4 st).
    @MainActor
    static var previewWithMovies: some View {
        RelatedMoviesSection(
            movies: PreviewFactory.recommendedMovies,
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }
    
    /// Preview showing empty state fallback when no movies are available.
    @MainActor
    static var previewEmpty: some View {
        RelatedMoviesSection(
            movies: [],
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing layout when only a single recommended movie exists.
    @MainActor
    static var previewSingleMovie: some View {
        RelatedMoviesSection(
            movies: [PreviewData.starWars],
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing horizontal scroll behavior with many recommended movies.
    @MainActor
    static var previewManyMovies: some View {
        RelatedMoviesSection(
            movies: Array(repeating: PreviewData.starWars, count: 10),
            movieViewModel: PreviewFactory.movieDetailViewModelWithRecommendations(),
            castViewModel: PreviewFactory.castViewModel()
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
