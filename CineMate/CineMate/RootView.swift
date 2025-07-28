//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator

    let movieVM: MovieViewModel
    let castVM: CastViewModel
    let favVM: FavoriteMoviesViewModel
    let searchVM: SearchViewModel
    let accountVM: AccountViewModel
    let discoverVM: DiscoverViewModel
    let personVM: PersonViewModel

    var body: some View {
        NavigationStack(path: $navigator.path) {
            TabView {
                MovieListView(viewModel: movieVM, castViewModel: castVM)
                    .tabItem { Label("Movies", systemImage: "film") }

                FavoriteMoviesView(viewModel: favVM)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }

                DiscoverView(viewModel: discoverVM)
                    .tabItem { Label("Discover", systemImage: "safari") }

                SearchView(viewModel: searchVM)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }

                AccountView(viewModel: accountVM)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .movieDetails(let m):
                    MovieDetailView(movie: m, viewModel: movieVM, castViewModel: castVM)
                case .personDetails(let p):
                    CastMemberDetailView(member: p, viewModel: personVM)
                case .crewDetails(let c):
                    CastMemberDetailView(member: CastMember(from: c), viewModel: personVM)
                case .genreDetails(let name):
                    GenreDetailView(genreName: name)
                }
            }
        }
    }
}

// MARK: - CrewMember → CastMember Convenience Extension

extension CastMember {
    init(from crew: CrewMember) {
        self.init(
            id: crew.id,
            name: crew.name,
            character: nil,
            profilePath: crew.profilePath
        )
    }
}
