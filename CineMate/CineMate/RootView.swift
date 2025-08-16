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
    let favoritePeopleVM: FavoritePeopleViewModel

    var body: some View {
        NavigationStack(path: $navigator.path) {

            TabView(selection: $selectedTab) {
                MovieListView(viewModel: movieVM, favoriteViewModel: favVM, castViewModel: castVM)
                    .tabItem { Label("Movies", systemImage: "film") }
                    .tag(MainTab.movies)


                FavoritesView(moviesVM: favVM, peopleVM: favoritePeopleVM)
                     .tabItem { Label("Favorites", systemImage: "heart.fill") }
                     .tag(MainTab.favorites)

                DiscoverView(viewModel: discoverVM)
                    .tabItem { Label("Discover", systemImage: "safari") }
                    .tag(MainTab.discover)

                SearchView(viewModel: searchVM, favoriteViewModel: favVM)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(MainTab.search)

                AccountView(viewModel: accountVM)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(MainTab.account)
            }
            .task { await favVM.startFavoritesListenerIfNeeded() }
            .task { await favoritePeopleVM.startFavoritesListenerIfNeeded() }
            //            .onDisappear { favVM.stopFavoritesListenerIfNeeded() } test if app crashes or has other unexpected behaviour
            .onChange(of: selectedTab) {
                navigator.reset()
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: debugRoute(route))
            }
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
                movieViewModel: movieVM,
                castViewModel: castVM,
                favoriteViewModel: favVM
            )

        case .person(let id):
            CastMemberDetailView(member: member(for: id),
                                 personViewModel: personVM,
                                 favoritePeopleVM: favoritePeopleVM)

        case .genre(let name):
            GenreDetailView(genreName: name)

        case .seeAllMovies(title: let title, filter: let filter):
            SeeAllMoviesView(
                viewModel: SeeAllMoviesViewModel(repository: movieVM.underlyingRepository, filter: filter),
                title: title
            )


        }
    }

    private func debugRoute(_ route: AppRoute) -> AppRoute {
#if DEBUG
        print("[RootView] resolving route: \(route); current path: \(navigator.path)")
#endif
        return route
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
