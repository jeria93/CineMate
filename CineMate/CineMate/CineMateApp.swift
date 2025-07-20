//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

@main
struct CineMate: App {
    @StateObject private var navigator = AppNavigator()

    var body: some Scene {
        WindowGroup {
            let repo        = MovieRepository()
            let movieVM     = MovieViewModel(repository: repo)
            let castVM      = CastViewModel(repository: repo)
            let favVM       = FavoriteMoviesViewModel()
            let searchVM    = SearchViewModel()
            let accountVM   = AccountViewModel()
            let discoverVM  = DiscoverViewModel(repository: repo)

            RootView(
                movieViewModel: movieVM,
                castViewModel: castVM,
                favoriteMoviesViewModel: favVM,
                searchViewModel: searchVM,
                accountViewModel: accountVM,
                discoverViewModel: discoverVM
            )
            .environmentObject(navigator)
        }
    }
}
