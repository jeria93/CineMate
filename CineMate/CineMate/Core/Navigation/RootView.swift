//
//  RootView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import SwiftUI

enum MainTab: String, CaseIterable, Hashable {
    case browse
    case search
    case favorites
    case account

    var title: String {
        switch self {
        case .browse: "Browse"
        case .search: "Search"
        case .favorites: "Favorites"
        case .account: "Account"
        }
    }

    var systemImage: String {
        switch self {
        case .browse: "square.grid.2x2.fill"
        case .search: "magnifyingglass"
        case .favorites: "heart.fill"
        case .account: "person.crop.circle"
        }
    }
}

/// Hosts shared tab navigation and keeps a separate route path for each tab.
/// It syncs favorites with the auth session and gates protected features for guests.
struct RootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var toastCenter: ToastCenter
    @State private var selectedTab: MainTab = .browse
    @State private var tabPaths: [MainTab: [AppRoute]] = [:]

    let movieVM: MovieViewModel
    let castVM: CastViewModel
    let favVM: FavoriteMoviesViewModel
    let searchVM: SearchViewModel
    let discoverVM: DiscoverViewModel
    let personVM: PersonViewModel
    let favoritePeopleVM: FavoritePeopleViewModel
    let authViewModel: AuthViewModel
    let authService: FirebaseAuthService?
    let isDemoMode: Bool

    var body: some View {
        NavigationStack(path: $navigator.path) {
            TabView(selection: $selectedTab) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    tabContent(for: tab)
                        .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                        .tag(tab)
                }
            }
            // Keep favorites listeners aligned with current auth session.
            .task(id: authViewModel.currentUID) {
                favVM.syncAuthState(uid: authViewModel.currentUID)
                favoritePeopleVM.syncAuthState(uid: authViewModel.currentUID)
            }

            // Preserve route history independently for each tab.
            .onChange(of: navigator.path) { _, newPath in
                tabPaths[selectedTab] = newPath
            }

            .onChange(of: selectedTab) { oldTab, newTab in
                guard oldTab != newTab else { return }
                tabPaths[oldTab] = navigator.path
                let restored = tabPaths[newTab] ?? []
                navigator.replacePath(
                    with: restored,
                    reason: "tab change \(oldTab.rawValue) -> \(newTab.rawValue)"
                )
            }

            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(.appPrimaryAction)
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            tabPaths[selectedTab] = navigator.path
        }
        .onDisappear {
            // Release listeners and clear session-scoped favorites on teardown.
            favVM.stopFavoritesListenerIfNeeded(keepCurrentState: false)
            favoritePeopleVM.stopFavoritesListenerIfNeeded(keepCurrentState: false)
        }
        .toast(toastCenter.message)
    }
}

extension RootView {
    @ViewBuilder
    private func tabContent(for tab: MainTab) -> some View {
        switch tab {
        case .browse:
            browseTab
        case .search:
            searchTab
        case .favorites:
            FavoritesView(moviesVM: favVM, peopleVM: favoritePeopleVM)
        case .account:
            accountTab
        }
    }

    @ViewBuilder
    private var browseTab: some View {
        if authViewModel.isGuest {
            // Preserve the movie browsing that was available before the tabs were merged.
            MovieListView(viewModel: movieVM, favoriteViewModel: favVM)
        } else {
            DiscoverView(viewModel: discoverVM)
        }
    }

    private var searchTab: some View {
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
    }

    private var accountTab: some View {
        Group {
            if isDemoMode {
                DemoAccountView()
            } else {
                AccountView(viewModel: authViewModel)
            }
        }
    }

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

        case .genre(let id, let name):
            GenreDetailView(
                genreId: id,
                genreName: name,
                repository: movieVM.underlyingRepository
            )
            .id(id)

        case .seeAllMovies(let title, let source):
            SeeAllMoviesView(
                viewModel: SeeAllMoviesViewModel(
                    repository: movieVM.underlyingRepository,
                    source: source
                ),
                title: title
            )

        case .createAccount:
            if let authService {
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
            } else {
                ContentUnavailableView(
                    "Unavailable in Demo",
                    systemImage: "person.crop.circle.badge.plus",
                    description: Text("Account creation requires the local Firebase configuration.")
                )
            }
        }
    }

    fileprivate func member(for id: Int) -> CastMember {
        castVM.cast.first(where: { $0.id == id })
        ?? castVM.crew.first(where: { $0.id == id }).map(CastMember.init(from:))
        ?? favoritePeopleVM.favorites.first(where: { $0.id == id }).map(CastMember.init(from:))
        ?? CastMember(id: id, name: "", character: nil, profilePath: nil)
    }
}

private struct DemoAccountView: View {
    var body: some View {
        Form {
            Section {
                Label("Demo mode", systemImage: "sparkles")
                    .font(.headline)

                Text(
                    "Explore CineMate with local sample data. "
                    + "Favorites stay in memory and no account is connected."
                )
                .foregroundStyle(.secondary)
            }

            Section("Portfolio Demo") {
                LabeledContent("Data", value: "Local samples")
                LabeledContent("Account", value: "Not connected")
            }
        }
        .navigationTitle("Account")
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
