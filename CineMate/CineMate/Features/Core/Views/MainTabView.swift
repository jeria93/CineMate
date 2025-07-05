//
//  MainTabView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct MainTabView: View {
    let movieViewModel: MovieViewModel
    let castViewModel: CastViewModel

    var body: some View {
        TabView {
            MovieListView(viewModel: movieViewModel, castViewModel: castViewModel)
                .tabItem {
                    Label("Movies", systemImage: "film")
                }

            FavoriteMoviesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainTabView.previewDefault
}
