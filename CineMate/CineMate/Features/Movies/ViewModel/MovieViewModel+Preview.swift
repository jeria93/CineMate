//
//  MovieViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

extension MovieViewModel {
    /// Preview instance of MovieViewModel with mock data.
    /// Used in SwiftUI previews to avoid real API calls.
    static var preview: MovieViewModel {
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.movies = PreviewData.moviesList
        return vm
    }
}
