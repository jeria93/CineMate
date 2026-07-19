//
//  CineMateApp.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import SwiftUI
import Foundation
import AppIntents

/// Application composition root for live and demo dependencies.
/// Live mode configures Firebase before Google Sign-In. Demo mode uses local
/// repositories and bypasses authentication. Shared view models live for the
/// app lifetime, and navigation resets when the authentication gate changes.
@main
struct CineMate: App {
    @StateObject private var navigator = AppNavigator()
    @StateObject private var toastCenter = ToastCenter()

    private let runtimeMode: AppRuntimeMode
    private let authService: FirebaseAuthService?

    @StateObject private var movieViewModel: MovieViewModel
    @StateObject private var castViewModel: CastViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var favoriteMoviesViewModel: FavoriteMoviesViewModel
    @StateObject private var discoverViewModel: DiscoverViewModel
    @StateObject private var personViewModel: PersonViewModel
    @StateObject private var favoritePeopleViewModel: FavoritePeopleViewModel
    @StateObject private var authViewModel: AuthViewModel
    
    /// Builds the dependency graph for the selected runtime mode.
    /// State objects preserve the view models for the app lifetime.
    init() {
        let mode = AppRuntimeMode.current
        let repo: MovieProtocol
        let auth: FirebaseAuthService?
        let authVM: AuthViewModel
        let favoriteMoviesVM: FavoriteMoviesViewModel
        let favoritePeopleVM: FavoritePeopleViewModel

        switch mode {
        case .demo:
            repo = MockMovieRepository()
            auth = nil
            authVM = AuthViewModel(simulatedUID: AppRuntimeMode.demoUserID)
            favoriteMoviesVM = .preview(
                with: Array(SharedPreviewMovies.moviesList.prefix(2))
            )
            favoritePeopleVM = FavoritePeopleViewModel(
                preview: FavoritePeoplePreviewData.few()
            )

        case .live:
            // Firebase must be configured before auth services are created.
            AppBootstrap.ensureConfigured()
            let liveAuth = FirebaseAuthService()
            repo = MovieRepository()
            auth = liveAuth
            authVM = AuthViewModel(service: liveAuth)
            favoriteMoviesVM = FavoriteMoviesViewModel(authService: liveAuth)
            favoritePeopleVM = FavoritePeopleViewModel(
                auth: liveAuth,
                repo: FirestoreFavoritePeopleRepository()
            )
        }

        runtimeMode = mode
        self.authService = auth

        _movieViewModel          = StateObject(wrappedValue: MovieViewModel(repository: repo))
        _castViewModel           = StateObject(wrappedValue: CastViewModel(repository: repo))
        _discoverViewModel       = StateObject(wrappedValue: DiscoverViewModel(repository: repo))
        _personViewModel         = StateObject(wrappedValue: PersonViewModel(repository: repo))
        _favoritePeopleViewModel = StateObject(wrappedValue: favoritePeopleVM)
        _authViewModel           = StateObject(wrappedValue: authVM)
        _searchViewModel         = StateObject(wrappedValue: SearchViewModel(repository: repo))
        _favoriteMoviesViewModel = StateObject(wrappedValue: favoriteMoviesVM)
    }
    
    var body: some Scene {
        WindowGroup {
            appRoot
                .environmentObject(navigator)
                .environmentObject(toastCenter)
                .onChange(of: authViewModel.currentUID) { oldUID, newUID in
                    handleSessionTransition(from: oldUID, to: newUID)
                }
                .handleGoogleSignInURL()
        }
    }
    
    @ViewBuilder
    private var appRoot: some View {
        if runtimeMode == .demo || authGateState == .signedIn {
            signedInRoot
        } else if let authService {
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
            authService: authService,
            isDemoMode: runtimeMode == .demo
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
        navigator.resetDeferred(reason: "auth gate transition \(fromState) -> \(toState)")
    }
    
    private func log(_ message: String) {
#if DEBUG
        print("[App][Nav][AuthGate] \(message)")
#endif
    }
}

private enum AuthGateState: Equatable {
    case signedOut
    case signedIn
}

/// Selects live dependencies only when both local configuration files are bundled.
/// Demo mode always uses local data. Live mode falls back to demo when configuration is incomplete.
enum AppRuntimeMode: Equatable {
    case demo
    case live

    static let environmentKey = "CINEMATE_RUNTIME"
    static let demoUserID = "cinemate-demo-user"

    static var current: AppRuntimeMode {
        resolve(
            environment: ProcessInfo.processInfo.environment,
            hasLiveConfiguration: LiveConfiguration.isAvailable
        )
    }

    static func resolve(
        environment: [String: String],
        hasLiveConfiguration: Bool
    ) -> AppRuntimeMode {
        let requestedMode = environment[environmentKey]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch requestedMode {
        case "demo":
            return .demo
        case "live":
            return hasLiveConfiguration ? .live : .demo
        default:
            return hasLiveConfiguration ? .live : .demo
        }
    }
}

private enum LiveConfiguration {
    static var isAvailable: Bool {
        Bundle.main.url(forResource: "Secrets", withExtension: "plist") != nil
        && Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
    }
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
