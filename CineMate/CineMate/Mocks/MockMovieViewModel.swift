//
//  MockMovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-08.
//

import Foundation

@MainActor
final class MockMovieViewModel: MovieViewModel {
    init() {
        super.init(repository: MockMovieRepository())
        self.movies = PreviewData.moviesList
        self.isLoading = false
        self.errorMessage = nil
    }
}
