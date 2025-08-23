//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

/// **App-entry (root DI-container)**
///
/// * Creates **one** shared `MovieRepository`.
/// * Bootstraps all long-living view models once and keeps them in `@StateObject`.
/// * Configures Firebase once via `FirebaseBootstrap.ensureConfigured()`.
/// * **Auth gate:** shows `LoginView` until a UID exists; then loads `RootView`.
/// * Provides a single `AppNavigator` (via `.environmentObject`) for enum-based navigation.
@main
struct CineMate: App {
    /// Global enum-navigation stack (`NavigationStack` binding lives in `RootView`).
    @StateObject private var navigator = AppNavigator()
    @StateObject private var toastCenter = ToastCenter()

    /// One shared repository instance (network + cache) kept by the app for reuse.
    private let repository: MovieRepository

    /// All long-living view-models are *owned* by the App struct.
    /// Created once in `init()` to survive view redraws and app-wide state changes.
    @StateObject private var movieViewModel            : MovieViewModel
    @StateObject private var castViewModel             : CastViewModel
    @StateObject private var searchViewModel           : SearchViewModel
    @StateObject private var favoriteMoviesViewModel   : FavoriteMoviesViewModel
    @StateObject private var discoverViewModel         : DiscoverViewModel
    @StateObject private var personViewModel           : PersonViewModel
    @StateObject private var favoritePeopleViewModel   : FavoritePeopleViewModel
    @StateObject private var authViewModel             : AuthViewModel

    /// Build DI-graph: repository -> view-models.
    /// `@StateObject` ensures identity/stability across lifecycle; VMs are constructed here.
    init() {
        FirebaseBootstrap.ensureConfigured() // Idempotent; no-op in Xcode Previews.

        let repo = MovieRepository()         // Single source of truth for movie data.
        self.repository = repo

        // Initialize view models that depend on the shared repository.
        _movieViewModel          = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castViewModel           = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverViewModel       = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personViewModel         = StateObject(wrappedValue: PersonViewModel(repository: repo))
        _favoritePeopleViewModel = StateObject(wrappedValue: FavoritePeopleViewModel())
        _authViewModel           = StateObject(wrappedValue: AuthViewModel(service: FirebaseAuthService()))
        _searchViewModel         = StateObject(wrappedValue: SearchViewModel(repository: repo))
        _favoriteMoviesViewModel = StateObject(wrappedValue: FavoriteMoviesViewModel())
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.currentUID == nil {
                NavigationStack(path: $navigator.path) {
                    LoginView(
                        viewModel: LoginViewModel(
                            service: FirebaseAuthService(),
                            onSuccess: { uid in
                                authViewModel.errorMessage = nil
                                authViewModel.isAuthenticating = false
                                authViewModel.currentUID = uid
                            }
                        )
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .createAccount:
                            CreateAccountView(
                                createViewModel: CreateAccountViewModel(
                                    service: FirebaseAuthService(),
                                    onVerificationEmailSent: {
                                        toastCenter.show("Check your inbox to verify your email")
                                        navigator.goBack()
                                    }
                                )
                            )

                        default:
                            EmptyView()
                        }
                    }
                }
                .environmentObject(navigator)
                .environmentObject(toastCenter)
            } else {
                RootView(
                    movieVM:          movieViewModel,
                    castVM:           castViewModel,
                    favVM:            favoriteMoviesViewModel,
                    searchVM:         searchViewModel,
                    discoverVM:       discoverViewModel,
                    personVM:         personViewModel,
                    favoritePeopleVM: favoritePeopleViewModel,
                    authViewModel:    authViewModel
                )
                .environmentObject(navigator)
                .environmentObject(toastCenter)
            }
        }
    }
}
