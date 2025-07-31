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
/// * Bootstraps all view-models with that repo (or empty in-memory impl.)
/// * Holds a single `AppNavigator` that powers enum-based navigation
/// * Injects everything into `RootView` and leaves the scene graph to SwiftUI
@main
struct CineMate: App {
    /// Global enum-navigation stack (`NavigationStack` binding lives in `RootView`)
    @StateObject private var navigator = AppNavigator()

    /// One shared repository instance (network + cache).
    /// Keeps strong ref so we can reuse - e.g. when adding new view-models later.
    private let repo: MovieRepository

    /// All long-living view-models are *owned* by the App struct.
    /// They’re created once and reused throughout the entire app life-cycle.
    @StateObject private var movieVM    : MovieViewModel
    @StateObject private var castVM     : CastViewModel
    @StateObject private var favVM      = FavoriteMoviesViewModel()
    @StateObject private var searchVM   = SearchViewModel()
    @StateObject private var accountVM  = AccountViewModel()
    @StateObject private var discoverVM : DiscoverViewModel
    @StateObject private var personVM   : PersonViewModel

    /// Build DI-graph: repo -> view-models.
    /// `StateObject` wrapper ensures each VM gets reference-counted and survives
    /// view redraws (e.g. when switching dark-mode, dynamic-type, etc.).
    init() {
        let repo = MovieRepository()      // single source of data / network
        self.repo = repo                  // keep for future injections

        // initialise view-models that depend on the repo
        _movieVM    = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castVM     = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverVM = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personVM   = StateObject(wrappedValue: PersonViewModel(repository: repo))
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                movieVM:          movieVM,
                castVM:           castVM,
                favVM:              favVM,
                searchVM:         searchVM,
                accountVM:        accountVM,
                discoverVM:       discoverVM,
                personVM:         personVM
            )
            // Make enum-navigation available to every child view.
            .environmentObject(navigator)
        }
    }
}
