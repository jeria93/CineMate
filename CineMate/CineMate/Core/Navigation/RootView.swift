//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

/// RootView
/// --------
/// What this view does:
/// - Hosts one shared `NavigationStack` via `AppNavigator`.
/// - Shows a `TabView` with five tabs: Movies, Favorites, Discover, Search, Account.
/// - Resolves navigation by pushing `AppRoute` values in `.navigationDestination`.
/// - Shows lightweight global toasts via `ToastCenter`.
///
/// Guest gating:
/// - If `authViewModel.isGuest` is true, **Discover** and **Search** are locked.
/// - We still render those screens but disable interaction and show a `LockedFeatureOverlay`.
/// - The overlay’s CTA routes to Create Account via `navigator.goToCreateAccount()`.
///
/// Design notes:
/// - Simple DI: long-lived view models are injected from the App root.
/// - View models do not perform navigation; routing is centralized here.
/// - One place controls guest gating so feature views stay clean.
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

    // Simple DI — long-lived VMs injected by the App
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
                        LockedFeatureOverlay(onCTA: { navigator.goToCreateAccount() })
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
                        favoriteViewModel: favVM,
                        isGuestMode: isLocked
                    )
                    .allowsHitTesting(!isLocked)
                    if isLocked {
                        LockedFeatureOverlay(onCTA: { navigator.goToCreateAccount() })
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
            // Start Firestore listeners when Root appears
            .task { await favVM.startFavoritesListenerIfNeeded() }
            .task { await favoritePeopleVM.startFavoritesListenerIfNeeded() }

            // Keep an up-to-date snapshot for the currently active tab.
            .onChange(of: navigator.path) { _, newPath in
                tabPaths[selectedTab] = newPath
            }

            // Restore the destination stack for the selected tab.
            .onChange(of: selectedTab) { oldTab, newTab in
                guard oldTab != newTab else { return }
                tabPaths[oldTab] = navigator.path
                let restored = tabPaths[newTab] ?? []
                navigator.replacePath(
                    with: restored,
                    reason: "tab change \(oldTab.rawValue) -> \(newTab.rawValue)"
                )
            }

            // Route -> destination
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .onAppear {
            tabPaths[selectedTab] = navigator.path
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
            // In-app (user is signed in, possibly anonymous → can upgrade)
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

    func member(for id: Int) -> CastMember {
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
