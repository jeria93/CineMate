//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// Root screen for tabs and app navigation.
/// Uses one shared `NavigationStack` with `AppNavigator`.
/// Shows lock overlays for guest users on protected tabs.
private enum MainTab: String, Hashable {
    case movies
    case favorites
    case discover
    case search
    case auth
}

struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @State private var selectedTab: MainTab = .movies
    @State private var tabPaths: [MainTab: [AppRoute]] = [:]

    // View models are injected from the app root.
    let movieVM: MovieViewModel
    let castVM: CastViewModel
    let favVM: FavoriteMoviesViewModel
    let searchVM: SearchViewModel
    let discoverVM: DiscoverViewModel
    let personVM: PersonViewModel
    let favoritePeopleVM: FavoritePeopleViewModel
    let authViewModel: AuthViewModel
    let authService: FirebaseAuthService

    var body: some View {
        NavigationStack(path: $navigator.path) {
            TabView(selection: $selectedTab) {
                // Movies tab
                MovieListView(viewModel: movieVM, favoriteViewModel: favVM)
                    .tabItem { Label("Movies", systemImage: "film") }
                    .tag(MainTab.movies)

                // Favorites tab
                FavoritesView(moviesVM: favVM, peopleVM: favoritePeopleVM)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag(MainTab.favorites)

                // Discover tab with guest lock
                ZStack {
                    let isLocked = authViewModel.isGuest
                    DiscoverView(viewModel: discoverVM)
                        .allowsHitTesting(!isLocked)
                    if isLocked {
                        LockedFeatureOverlay(onCTA: { navigator.goToCreateAccount() })
                            .zIndex(1)
                    }
                }
                .tabItem { Label("Discover", systemImage: "safari") }
                .tag(MainTab.discover)

                // Search tab with guest lock
                ZStack {
                    let isLocked = authViewModel.isGuest
                    SearchView(
                        searchViewModel: searchVM,
                        favoriteViewModel: favVM,
                        isGuestMode: isLocked
                    )
                    .allowsHitTesting(!isLocked)
                    if isLocked {
                        LockedFeatureOverlay(onCTA: { navigator.goToCreateAccount() })
                            .zIndex(1)
                    }
                }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(MainTab.search)

                // Account tab
                AccountView(viewModel: authViewModel)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
                    .tag(MainTab.auth)
            }
            // Keep favorites listeners aligned with current auth session.
            .task(id: authViewModel.currentUID) {
                favVM.syncAuthState(uid: authViewModel.currentUID)
                favoritePeopleVM.syncAuthState(uid: authViewModel.currentUID)
            }

            // Save the path for the active tab.
            .onChange(of: navigator.path) { _, newPath in
                tabPaths[selectedTab] = newPath
            }

            // Restore the path when the tab changes.
            .onChange(of: selectedTab) { oldTab, newTab in
                guard oldTab != newTab else { return }
                tabPaths[oldTab] = navigator.path
                let restored = tabPaths[newTab] ?? []
                navigator.replacePath(
                    with: restored,
                    reason: "tab change \(oldTab.rawValue) -> \(newTab.rawValue)"
                )
            }

            // Build a destination for each route.
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .onAppear {
            tabPaths[selectedTab] = navigator.path
        }
        .onDisappear {
            // RootView only exists in signed-in flow, so clear state on teardown.
            favVM.stopFavoritesListenerIfNeeded(keepCurrentState: false)
            favoritePeopleVM.stopFavoritesListenerIfNeeded(keepCurrentState: false)
        }
        .toast(toastCenter.message)
    }
}

extension RootView {
    @ViewBuilder
    fileprivate func destination(for route: AppRoute) -> some View {
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
                favoritePeopleVM: favoritePeopleVM,
                movieViewModel: movieVM
            )

        case .genre(let name):
            GenreDetailView(genreName: name)

        case .seeAllMovies(let title, let filter):
            SeeAllMoviesView(
                viewModel: SeeAllMoviesViewModel(
                    repository: movieVM.underlyingRepository,
                    filter: filter
                ),
                title: title
            )

        case .createAccount:
            // Signed in users can still upgrade anonymous accounts.
            CreateAccountView(
                createViewModel: CreateAccountViewModel(
                    service: authService,
                    onVerificationEmailSent: {
                        toastCenter.show("Check your inbox to verify your email")
                        navigator.goBack()
                    }
                )
            )
        }
    }

    fileprivate func member(for id: Int) -> CastMember {
        castVM.cast.first(where: { $0.id == id })
        ?? castVM.crew.first(where: { $0.id == id }).map(CastMember.init(from:))
        ?? favoritePeopleVM.favorites.first(where: { $0.id == id }).map(CastMember.init(from:))
        ?? CastMember(id: id, name: "", character: nil, profilePath: nil)
    }
}

extension CastMember {
    init(from crew: CrewMember) {
        self.init(id: crew.id, name: crew.name, character: nil, profilePath: crew.profilePath)
    }

    init(from person: PersonRef) {
        self.init(id: person.id, name: person.name, character: nil, profilePath: person.profilePath)
    }
}
