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
            let viewModel = MovieViewModel(repository: repository)

            MovieListView(
                viewModel: viewModel,
                castViewModelProvider: {
                    CastViewModel(repository: repository)
                }
            )
        }
    }
}
