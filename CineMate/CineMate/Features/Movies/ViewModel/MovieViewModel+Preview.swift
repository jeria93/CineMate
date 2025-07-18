//
//  MovieViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

/// Extension that provides a mock `MovieViewModel` for SwiftUI previews.
///
/// This avoids real API calls and enables UI testing with controlled mock data.
extension MovieViewModel {

    /// A configured `MovieViewModel` with a list of mock movies.
    ///
    /// - Calls `PreviewID.reset()` to ensure unique movie IDs.
    /// - Injects `MockMovieRepository` to avoid real API dependency.
    static var preview: MovieViewModel {
        PreviewID.reset()
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }
}
