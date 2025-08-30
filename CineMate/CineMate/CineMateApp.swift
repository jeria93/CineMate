//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

/// **CineMateApp – DI root & bootstrap**
///
/// What this does:
/// - Starts SDKs **once** per app run (skips Xcode Previews)
///   1) `FirebaseBootstrap.ensureConfigured()`
///   2) `GoogleSignInBootstrap.ensureConfigured()` (reads `clientID` from Firebase)
/// - Builds shared services as `let` (`MovieRepository`, `FirebaseAuthService`)
/// - Owns long-lived view models as `@StateObject` (created in `init()` from those services)
/// - Auth gate: **signed out** → `LoginView`, **signed in** → `RootView`
/// - Shares global env objects: `AppNavigator`, `ToastCenter`
/// - Handles Google redirect app-wide via `.handleGoogleSignInURL()` on `WindowGroup`
@main
struct CineMate: App {
    /// Global enum-navigation stack (`NavigationStack` binding lives in `RootView`).
    @StateObject private var navigator = AppNavigator()
    @StateObject private var toastCenter = ToastCenter()

    /// One shared repository instance (network + cache) kept by the app for reuse.
    private let repository: MovieRepository
    private let authService: FirebaseAuthService

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
        // Order matters: configure Firebase first
        // GoogleSignInBootstrap reads clientID from FirebaseApp.options
        FirebaseBootstrap.ensureConfigured()
        GoogleSignInBootstrap.ensureConfigured()

        let repo = MovieRepository()
        let auth = FirebaseAuthService()
        self.repository  = repo
        self.authService = auth

        // Initialize view models that depend on the shared repository.
        _movieViewModel          = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castViewModel           = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverViewModel       = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personViewModel         = StateObject(wrappedValue: PersonViewModel(repository: repo))
        _favoritePeopleViewModel = StateObject(wrappedValue: FavoritePeopleViewModel())
        _authViewModel           = StateObject(wrappedValue: AuthViewModel(service: auth))
        _searchViewModel         = StateObject(wrappedValue: SearchViewModel(repository: repo))
        _favoriteMoviesViewModel = StateObject(wrappedValue: FavoriteMoviesViewModel())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.currentUID == nil {
                    NavigationStack(path: $navigator.path) {
                        LoginView(
                            viewModel: LoginViewModel(
                                service: authService,
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
                                        service: authService,
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
                }
            }
            .environmentObject(navigator)
            .environmentObject(toastCenter)
            .handleGoogleSignInURL()
        }
    }
}
