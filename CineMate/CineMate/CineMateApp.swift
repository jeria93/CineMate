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
            
            MainTabView(
                movieViewModel: movieViewModel,
                castViewModel: castViewModel
            )
        }
    }
}
