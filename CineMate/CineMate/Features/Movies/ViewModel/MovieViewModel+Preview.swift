//
//  MovieViewModel+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

extension MovieViewModel {
    /// Preview instance of MovieViewModel with mock data.
    /// Used in SwiftUI previews to avoid real API calls.
    static var preview: MovieViewModel {
        PreviewID.reset()
        let vm = MovieViewModel(repository: MockMovieRepository())
        vm.movies = SharedPreviewMovies.moviesList
        return vm
    }
}
