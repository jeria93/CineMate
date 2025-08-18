//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

/// **App-entry (root DI-container)**
///
/// * Creates **one** shared `MovieRepository`
/// * Bootstraps all view-models with that repository (or empty in-memory impl.)
/// * Holds a single `AppNavigator` that powers enum-based navigation
/// * Injects everything into `RootView` and leaves the scene graph to SwiftUI
@main
struct CineMate: App {
    /// Global enum-navigation stack (`NavigationStack` binding lives in `RootView`)
    @StateObject private var navigator = AppNavigator()

    /// One shared repository instance (network + cache).
    /// Keeps strong ref so we can reuse - e.g. when adding new view-models later.
    private let repository: MovieRepository

    /// All long-living view-models are *owned* by the App struct.
    /// They’re created once and reused throughout the entire app life-cycle.
    @StateObject private var movieViewModel    : MovieViewModel
    @StateObject private var castViewModel     : CastViewModel
    @StateObject private var searchViewModel : SearchViewModel
    @StateObject private var favoriteMoviesViewModel : FavoriteMoviesViewModel
    @StateObject private var discoverViewModel : DiscoverViewModel
    @StateObject private var personViewModel   : PersonViewModel
    @StateObject private var favoritePeopleViewModel: FavoritePeopleViewModel
    @StateObject private var authViewModel: AuthViewModel
    /// Build DI-graph: repository -> view-models.
    /// `StateObject` wrapper ensures each VM gets reference-counted and survives
    /// view redraws (e.g. when switching dark-mode, dynamic-type, etc.).
    init() {

        FirebaseBootstrap.ensureConfigured() // Bootstrap Firebase

        let repo = MovieRepository()      // single source of data / network
        self.repository = repo                  // keep for future injections

        // initialise view-models that depend on the repository
        _movieViewModel    = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castViewModel     = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personViewModel   = StateObject(wrappedValue: PersonViewModel(repository: repo))
        _favoritePeopleViewModel = StateObject(wrappedValue: FavoritePeopleViewModel())
        _authViewModel = StateObject(wrappedValue: AuthViewModel(service: FirebaseAuthService()))
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(repository: repo))
        _favoriteMoviesViewModel = StateObject(wrappedValue: FavoriteMoviesViewModel()) }

    var body: some Scene {
        WindowGroup {
            RootView(
                movieVM:          movieViewModel,
                castVM:           castViewModel,
                favVM:              favoriteMoviesViewModel,
                searchVM:         searchViewModel,
                discoverVM:       discoverViewModel,
                personVM:         personViewModel,
                favoritePeopleVM: favoritePeopleViewModel,
                authViewModel: authViewModel
            )
            // Make enum-navigation available to every child view.
            .environmentObject(navigator)
        }
    }
}
