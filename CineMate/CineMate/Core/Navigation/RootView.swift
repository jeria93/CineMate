//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// RootView
/// --------
/// • Hosts a single shared `NavigationStack` via `AppNavigator`.
/// • Five tabs: Movies, Favorites, Discover, Search, Account.
/// • Navigation via `AppRoute` resolved in `navigationDestination`.
/// • Shows global toasts via `ToastCenter`.
///
/// Guest gating:
/// • When `authViewModel.isGuest`, **Discover** and **Search** are disabled
///   and covered by `LockedFeatureOverlay` (fixed title, only `onCTA:` passed).
private enum MainTab: Hashable {
    case movies, favorites, discover, search, auth
}

struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @State private var selectedTab: MainTab = .movies

    // Simple DI — long-lived VMs injected by the App
    let movieVM: MovieViewModel
    let castVM: CastViewModel
    let favVM: FavoriteMoviesViewModel
    let searchVM: SearchViewModel
    let discoverVM: DiscoverViewModel
    let personVM: PersonViewModel
    let favoritePeopleVM: FavoritePeopleViewModel
    let authViewModel: AuthViewModel

    var body: some View {
        NavigationStack(path: $navigator.path) {
            TabView(selection: $selectedTab) {
                // Movies
                MovieListView(viewModel: movieVM, favoriteViewModel: favVM, castViewModel: castVM)
                    .tabItem { Label("Movies", systemImage: "film") }
                    .tag(MainTab.movies)

                // Favorites
                FavoritesView(moviesVM: favVM, peopleVM: favoritePeopleVM)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag(MainTab.favorites)

                // Discover — locked for guests
                ZStack {
                    let isLocked = authViewModel.isGuest

                    DiscoverView(viewModel: discoverVM)
                        .allowsHitTesting(!isLocked)

                    if isLocked {
                        LockedFeatureOverlay()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .zIndex(1)
                    }
                }
                .tabItem { Label("Discover", systemImage: "safari") }
                .tag(MainTab.discover)

                // Search — locked for guests
                ZStack {
                    let isLocked = authViewModel.isGuest

                    SearchView(
                        searchViewModel: searchVM,
                        favoriteViewModel: favVM
                    )
                    .allowsHitTesting(!isLocked)

                    if isLocked {
                        LockedFeatureOverlay()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .zIndex(1)
                    }
                }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(MainTab.search)
                // Account
                AccountView(viewModel: authViewModel)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(MainTab.auth)
            }
            .task { await favVM.startFavoritesListenerIfNeeded() }
            .task { await favoritePeopleVM.startFavoritesListenerIfNeeded() }
            .onChange(of: selectedTab) { _,_ in navigator.reset() }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: debugRoute(route))
            }
        }
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
                    repository: movieVM.underlyingRepository,
                    filter: filter
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
        print("[RootView] resolving route: \(route); current path: \(navigator.path)")
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
