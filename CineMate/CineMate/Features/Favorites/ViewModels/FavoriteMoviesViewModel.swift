//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// # FavoriteMoviesViewModel
///
/// ViewModel responsible for **Favorites** feature state management.
/// Coordinates between Firebase Authentication and Firestore to:
/// - Ensure a user session exists (anonymous sign-in if needed)
/// - Maintain a real-time stream of the user's favorite movies
/// - Optimistically add/remove favorites in response to user actions
///
/// ## Responsibilities
/// 1. **Expose state** (`favoriteMovies`, `isLoading`, `errorMessage`) for the UI to render
/// 2. **Start/stop** a Firestore real-time listener for the current user's favorites
/// 3. **Prevent duplicates** by avoiding multiple concurrent listeners
/// 4. **Handle errors** and only show loading on the first fetch
/// 5. **Toggle favorites** optimistically for fast UI feedback
///
/// ## Usage
/// ```swift
/// @StateObject var favVM = FavoriteMoviesViewModel()
///
/// // View lifecycle
/// .task { await favVM.startFavoritesListenerIfNeeded() }
/// .onDisappear { favVM.stopFavoritesListenerIfNeeded() }
///
/// // Toggle from a button
/// Button {
///     Task { await favVM.toggleFavorite(movie: movie) }
/// } label: { ... }
/// ```
///
/// ## Notes
/// - Runs on `@MainActor` for safe UI state updates
/// - Firestore stream runs in a background task and only hops to main actor for `@Published` changes
/// - Caches state between navigations to avoid UI flicker
@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    // MARK: - Published UI State

    /// List of movies currently marked as favorites
    @Published var favoriteMovies: [Movie] = []

    /// Indicates if the initial data load is in progress
    @Published var isLoading = false

    /// Contains an error message for the UI if loading fails
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies

    /// Firestore repository for reading/writing favorites
    private let repository: FirestoreFavoritesRepository

    /// Authentication service to ensure a valid (anonymous) user session
    private let authService: FirebaseAuthService

    // MARK: - Runtime Flags

    /// Active Firestore listener task
    private var favoritesTask: Task<Void, Never>? = nil

    /// Tracks whether at least one successful load has completed
    private var hasLoadedOnce = false

    /// Prevents starting multiple listeners at the same time
    private var isListening = false

    // MARK: - Init / Deinit

    init(
        repository: FirestoreFavoritesRepository = .init(),
        authService: FirebaseAuthService = .init()
    ) {
        self.repository = repository
        self.authService = authService
    }

    deinit {
        favoritesTask?.cancel()
    }

    // MARK: - View Lifecycle Hooks

    /// Starts the real-time Firestore listener if not already running
    /// - Skips execution in Xcode previews
    /// - Shows loading only on the very first fetch
    func startFavoritesListenerIfNeeded() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard !isListening else { return }

        isListening = true
        errorMessage = nil
        if !hasLoadedOnce {
            isLoading = true
        }

        do {
            let uid = try await authService.isLoggedIn()

            // Cancel any existing listener before starting a new one
            favoritesTask?.cancel()
            favoritesTask = Task { [repository] in
                for await movies in repository.favoritesStream(for: uid) {
                    await MainActor.run {
                        self.favoriteMovies = movies
                        self.isLoading = false
                        self.hasLoadedOnce = true
                        self.errorMessage = nil
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isListening = false
        }
    }

    /// Stops the real-time listener without clearing the current data
    /// - This prevents UI flicker when navigating back to the view
    func stopFavoritesListenerIfNeeded() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        favoritesTask?.cancel()
        favoritesTask = nil
        isListening = false
    }

    // MARK: - User Actions

    /// Toggles a movie as favorite for the current user
    /// - Optimistically updates the UI before Firestore confirms
    /// - Falls back to stream data if any conflict occurs
    func toggleFavorite(movie: Movie) async {
        do {
            let uid = try await authService.isLoggedIn()

            if favoriteMovies.contains(where: { $0.id == movie.id }) {
                try await repository.removeFavorite(id: movie.id, for: uid)
                favoriteMovies.removeAll { $0.id == movie.id }
            } else {
                try await repository.addFavorite(movie: movie, for: uid)
                favoriteMovies.insert(movie, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
