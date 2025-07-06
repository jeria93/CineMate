//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

@main
struct CineMate: App {
    var body: some Scene {
        WindowGroup {
            let repository = MovieRepository()
            let movieViewModel = MovieViewModel(repository: repository)
            let castViewModel = CastViewModel(repository: repository)
            let favoriteMoviesViewModel = FavoriteMoviesViewModel()
            let searchViewModel = SearchViewModel()
            let accountViewModel = AccountViewModel()

            MainTabView(
                movieViewModel: movieViewModel,
                castViewModel: castViewModel,
                favoriteMoviesViewModel: favoriteMoviesViewModel,
                searchViewModel: searchViewModel,
                accountViewModel: accountViewModel
            )
        }
    }
}
