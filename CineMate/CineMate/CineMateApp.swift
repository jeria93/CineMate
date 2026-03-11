//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI
import Foundation

/// CineMateApp — DI root & bootstrap
///
/// What this app struct is responsible for:
/// - Configure SDKs **once** on launch (skips Xcode Previews).
///   1) `FirebaseBootstrap.ensureConfigured()`
///   2) `GoogleSignInBootstrap.ensureConfigured()` (uses Firebase clientID)
/// - Build shared services as `let` (e.g. `MovieRepository`, `FirebaseAuthService`)
/// - Create and own long-lived view models as `@StateObject`
/// - Switch UI:
///   • **Signed out** --> `LoginView` flow
///   • **Signed in**  --> `RootView` (tab bar)
/// - Inject environment objects intentionally:
///   • both auth branches receive `ToastCenter`
///   • `AppNavigator` is shared app-wide (used by signed-in flow)
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
    private let authService: FirebaseAuthService

    // Long-lived view models (owned by the App)
    @StateObject private var movieViewModel: MovieViewModel
    @StateObject private var castViewModel: CastViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var favoriteMoviesViewModel: FavoriteMoviesViewModel
    @StateObject private var discoverViewModel: DiscoverViewModel
    @StateObject private var personViewModel: PersonViewModel
    @StateObject private var favoritePeopleViewModel: FavoritePeopleViewModel
    @StateObject private var authViewModel: AuthViewModel

    /// Build the DI graph (services -> view models).
    /// `@StateObject` ensures each VM is created once and reused.
    init() {
        // Order is enforced once at app-level bootstrap.
        AppBootstrap.ensureConfigured()

        let repo = MovieRepository()
        let auth = FirebaseAuthService()
        let authVM = AuthViewModel(service: auth)
        self.authService = auth

        // Create VMs that depend on the shared services
        _movieViewModel          = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castViewModel           = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverViewModel       = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personViewModel         = StateObject(wrappedValue: PersonViewModel(repository: repo))
        _favoritePeopleViewModel = StateObject(
            wrappedValue: FavoritePeopleViewModel(
                auth: auth,
                repo: FirestoreFavoritePeopleRepository()
            )
        )
        _authViewModel           = StateObject(wrappedValue: authVM)
        _searchViewModel         = StateObject(wrappedValue: SearchViewModel(repository: repo))
        _favoriteMoviesViewModel = StateObject(
            wrappedValue: FavoriteMoviesViewModel(authService: auth)
        )
    }

    var body: some Scene {
        WindowGroup {
            appRoot
                .environmentObject(navigator)
                .environmentObject(toastCenter)
                .onChange(of: authViewModel.currentUID) { oldUID, newUID in
                    handleSessionTransition(from: oldUID, to: newUID)
                }
            // App-wide Google sign-in redirect handler
                .handleGoogleSignInURL()
        }
    }

    @ViewBuilder
    private var appRoot: some View {
        switch authGateState {
        case .signedIn:
            signedInRoot
        case .signedOut:
            SignedOutRootView(authService: authService, onSignedIn: handleSignIn)
        }
    }

    private var authGateState: AuthGateState {
        authViewModel.currentUID == nil ? .signedOut : .signedIn
    }

    private var signedInRoot: some View {
        RootView(
            movieVM: movieViewModel,
            castVM: castViewModel,
            favVM: favoriteMoviesViewModel,
            searchVM: searchViewModel,
            discoverVM: discoverViewModel,
            personVM: personViewModel,
            favoritePeopleVM: favoritePeopleViewModel,
            authViewModel: authViewModel,
            authService: authService
        )
    }

    private func handleSignIn(_ uid: String) {
        authViewModel.errorMessage = nil
        authViewModel.isAuthenticating = false
        if authViewModel.currentUID != uid {
            authViewModel.currentUID = uid
        }
    }

    private func handleSessionTransition(from oldUID: String?, to newUID: String?) {
        let fromSignedIn = oldUID != nil
        let toSignedIn = newUID != nil
        guard fromSignedIn != toSignedIn else { return }

        let fromState = fromSignedIn ? "signedIn" : "signedOut"
        let toState = toSignedIn ? "signedIn" : "signedOut"
        log("auth gate transition \(fromState) -> \(toState)")
        navigator.reset(reason: "auth gate transition \(fromState) -> \(toState)")
    }

    private func log(_ message: String) {
#if DEBUG
        print("[App][Nav][AuthGate] \(message)")
#endif
    }
}

private enum AuthGateState {
    case signedOut
    case signedIn
}

private enum SignedOutRoute: Hashable {
    case createAccount
}

private struct SignedOutRootView: View {
    @EnvironmentObject private var toastCenter: ToastCenter
    @State private var path: [SignedOutRoute] = []
    @StateObject private var loginViewModel: LoginViewModel

    private let authService: FirebaseAuthService

    init(authService: FirebaseAuthService, onSignedIn: @escaping (String) -> Void) {
        self.authService = authService
        _loginViewModel = StateObject(
            wrappedValue: LoginViewModel(service: authService, onSuccess: onSignedIn)
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(
                viewModel: loginViewModel,
                onRegister: { path.append(.createAccount) }
            )
            .navigationDestination(for: SignedOutRoute.self) { route in
                switch route {
                case .createAccount:
                    CreateAccountView(
                        createViewModel: CreateAccountViewModel(
                            service: authService,
                            onVerificationEmailSent: {
                                toastCenter.show("Check your inbox to verify your email")
                                path.removeAll()
                            }
                        )
                    )
                }
            }
        }
        .toast(toastCenter.message)
    }
}

/// App-level bootstrap coordinator. Guarantees launch SDK order exactly once:
/// Firebase first, Google Sign-In second.
private enum AppBootstrap {
    private static let lock = NSLock()
    private static var didRun = false

    static func ensureConfigured() {
        guard !ProcessInfo.processInfo.isPreview else { return }

        lock.lock()
        defer { lock.unlock() }

        guard !didRun else {
            log("bootstrap skipped (already completed)")
            return
        }

        log("bootstrap start")
        FirebaseBootstrap.ensureConfigured()
        GoogleSignInBootstrap.ensureConfigured()
        didRun = true
        log("bootstrap complete")
    }

    private static func log(_ message: String) {
#if DEBUG
        print("[App][Bootstrap] \(message)")
#endif
    }
}
