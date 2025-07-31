//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// RootView
/// --------
/// * Hosts a single shared `NavigationStack` via `AppNavigator`.
/// * Displays a five-tab `TabView` (Movies, Favorites, Discover, Search, Account).
/// * Navigation is driven by calling `navigator.goTo…`, which pushes an `AppRoute`.
/// * `navigationDestination(for:)` resolves each route to its corresponding view.
///
/// Design principles:
/// * Enum-based routing centralized here.
/// * ID-based routes for lightweight, stable hashing.
/// * ViewModels remain free of navigation logic; this view orchestrates destinations.

private enum MainTab: Hashable {
    case movies
    case favorites
    case discover
    case search
    case account
}

struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @State private var selectedTab : MainTab = .movies

    // View-models injected from the App entry
    let movieVM   : MovieViewModel
    let castVM    : CastViewModel
    let favVM     : FavoriteMoviesViewModel
    let searchVM  : SearchViewModel
    let accountVM : AccountViewModel
    let discoverVM: DiscoverViewModel
    let personVM  : PersonViewModel

    var body: some View {
        NavigationStack(path: $navigator.path) {

            TabView(selection: $selectedTab) {
                MovieListView(viewModel: movieVM, castViewModel: castVM)
                    .tabItem { Label("Movies", systemImage: "film") }
                    .tag(MainTab.movies)


                FavoriteMoviesView(viewModel: favVM)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag(MainTab.favorites)

                DiscoverView(viewModel: discoverVM)
                    .tabItem { Label("Discover", systemImage: "safari") }
                    .tag(MainTab.discover)

                SearchView(viewModel: searchVM)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(MainTab.search)

                AccountView(viewModel: accountVM)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(MainTab.account)
            }
            .onChange(of: selectedTab) {
                navigator.reset()
            }
            .navigationDestination(
                for: AppRoute.self,
                destination: destination
            )
        }
    }
}

private extension RootView {

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {

        case .movie(let id):
            MovieDetailView(
                movieId: id,
                viewModel: movieVM,
                castViewModel: castVM
            )

        case .person(let id):
            CastMemberDetailView(member: member(for: id),
                                 viewModel: personVM)

        case .genre(let name):
            GenreDetailView(genreName: name)
        }
    }

    /// Resolves a cast/crew member by id, falling back to a minimal placeholder.
    func member(for id: Int) -> CastMember {
        castVM.cast.first(where: { $0.id == id })
        ?? castVM.crew.first(where: { $0.id == id }).map(CastMember.init(from:))
        ?? CastMember(id: id, name: "", character: nil, profilePath: nil)
    }
}

extension CastMember {
    init(from crew: CrewMember) {
        self.init(id: crew.id, name: crew.name,
                  character: nil, profilePath: crew.profilePath)
    }
}
