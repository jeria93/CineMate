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
/// * Requires a `ToastCenter` environment object to display lightweight, global toasts
///   (e.g. after account creation / email verification prompt).
///
/// Design principles:
/// * Enum-based routing centralized here.
/// * ID-based routes for lightweight, stable hashing.
/// * ViewModels remain free of navigation logic; this view orchestrates destinations.
/// * Side-effects like toasts are delegated to environment services (e.g. `ToastCenter`).
private enum MainTab: Hashable {
    case movies
    case favorites
    case discover
    case search
    case auth
}

struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter   // Injected by App entry
    @State private var selectedTab : MainTab = .movies

    // View-models injected from the App entry
    let movieVM   : MovieViewModel
    let castVM    : CastViewModel
    let favVM     : FavoriteMoviesViewModel
    let searchVM  : SearchViewModel
    let discoverVM: DiscoverViewModel
    let personVM  : PersonViewModel
    let favoritePeopleVM: FavoritePeopleViewModel
    let authViewModel: AuthViewModel

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

                AccountView(viewModel: authViewModel)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(MainTab.auth)
            }
            .task { await favVM.startFavoritesListenerIfNeeded() }
            .task { await favoritePeopleVM.startFavoritesListenerIfNeeded() }
            .onChange(of: selectedTab) { navigator.reset() }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: debugRoute(route))
            }
        }
        // Uses ToastCenter.message to overlay a global toast on this screen tree
        .toast(toastCenter.message)
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
            CastMemberDetailView(
                member: member(for: id),
                personViewModel: personVM,
                favoritePeopleVM: favoritePeopleVM
            )

        case .genre(let name):
            GenreDetailView(genreName: name)

        case .seeAllMovies(title: let title, filter: let filter):
            SeeAllMoviesView(
                viewModel: SeeAllMoviesViewModel(
                    repository: movieVM.underlyingRepository, filter: filter
                ),
                title: title
            )

        case .createAccount:
            // After sending verification email, show toast and pop back.
            CreateAccountView(
                createViewModel: CreateAccountViewModel(
                    service: FirebaseAuthService(),
                    onVerificationEmailSent: {
                        toastCenter.show("Check your inbox to verify your email")
                        navigator.goBack()
                    }
                )
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
        self.init(id: crew.id, name: crew.name, character: nil, profilePath: crew.profilePath)
    }
}
