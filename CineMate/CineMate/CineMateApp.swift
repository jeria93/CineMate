//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI

/// CineMateApp — DI root & bootstrap
///
/// What this app struct is responsible for:
/// - Configure SDKs **once** on launch (skips Xcode Previews).
///   1) `FirebaseBootstrap.ensureConfigured()`
///   2) `GoogleSignInBootstrap.ensureConfigured()` (uses Firebase clientID)
/// - Build shared services as `let` (e.g. `MovieRepository`, `FirebaseAuthService`)
/// - Create and own long-lived view models as `@StateObject`
/// - Switch UI:
///   • **Signed out** -> `LoginView` flow
///   • **Signed in**  -> `RootView` (tab bar)
/// - Provide global environment objects: `AppNavigator`, `ToastCenter`
/// - Handle Google sign-in callback via `.handleGoogleSignInURL()`
///
/// Notes:
/// - View models are created in `init()` so they keep identity across view reloads.
/// - Services are injected into view models (Simple DI).
@main
struct CineMate: App {
    // Global enum-based navigation (bound to `NavigationStack` in RootView)
    @StateObject private var navigator = AppNavigator()

    // Lightweight global toast service
    @StateObject private var toastCenter = ToastCenter()

    // Shared services (network/auth)
    private let repository: MovieRepository
    private let authService: FirebaseAuthService

    // Long-lived view models (owned by the App)
    @StateObject private var movieViewModel          : MovieViewModel
    @StateObject private var castViewModel           : CastViewModel
    @StateObject private var searchViewModel         : SearchViewModel
    @StateObject private var favoriteMoviesViewModel : FavoriteMoviesViewModel
    @StateObject private var discoverViewModel       : DiscoverViewModel
    @StateObject private var personViewModel         : PersonViewModel
    @StateObject private var favoritePeopleViewModel : FavoritePeopleViewModel
    @StateObject private var authViewModel           : AuthViewModel

    /// Build the DI graph (services -> view models).
    /// `@StateObject` ensures each VM is created once and reused.
    init() {
        // Order matters: Firebase first, Google next (reads Firebase clientID)
        FirebaseBootstrap.ensureConfigured()
        GoogleSignInBootstrap.ensureConfigured()

        let repo = MovieRepository()
        let auth = FirebaseAuthService()
        self.repository  = repo
        self.authService = auth

        // Create VMs that depend on the shared services
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
                // Simple auth gate
                if authViewModel.currentUID == nil {
                    // LOGIN / SIGN-UP FLOW
                    NavigationStack(path: $navigator.path) {
                        LoginView(
                            viewModel: LoginViewModel(
                                service: authService,
                                onSuccess: { uid in
                                    // Bubble up the new session to the app-owned auth VM
                                    authViewModel.errorMessage = nil
                                    authViewModel.isAuthenticating = false
                                    authViewModel.currentUID = uid
                                }
                            )
                        )
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .createAccount:
                                // Create Account inside the login flow
                                CreateAccountView(
                                    createViewModel: CreateAccountViewModel(
                                        service: authService,
                                        onVerificationEmailSent: {
                                            toastCenter.show("Check your inbox to verify your email")
                                            navigator.goBack()
                                        },
                                        onUpgraded: {
                                            // If the user was anonymous -> now linked and signed in
                                            if let uid = authService.currentUserID {
                                                authViewModel.currentUID = uid
                                                authViewModel.errorMessage = nil
                                                authViewModel.isAuthenticating = false
                                            }
                                            toastCenter.show("Account created! You’re all set.")
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
                    // MAIN APP
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
            // Global environment
            .environmentObject(navigator)
            .environmentObject(toastCenter)
            // App-wide Google sign-in redirect handler
            .handleGoogleSignInURL()
        }
    }
}
