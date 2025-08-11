//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// # FavoriteMoviesViewModel
/// ViewModel that owns the **Favorites** UI state and coordinates between
/// Firebase Auth and Firestore. It can:
/// - ensure the user is signed in (anonymous if needed),
/// - stream favorites in real time,
/// - optimistically toggle favorites (add/remove).
///
/// ## Responsibilities
/// 1) Expose `favoriteMovies` for the UI to render.
/// 2) Start/stop a real-time Firestore listener (stream).
/// 3) Ensure a user session exists before any Firestore work.
/// 4) Toggle a movie as favorite and keep state consistent.
///
/// ## Usage
/// ```swift
/// @StateObject var favVM = FavoriteMoviesViewModel()
///
/// // Start/stop live updates with the view’s lifecycle
/// .task { await favVM.startFavoritesListener() }
/// .onDisappear { favVM.stopFavoritesListener() }
///
/// // Toggle from a row button
/// Button { Task { await favVM.toggleFavorite(movie: movie) } } label: { ... }
/// ```
///
/// Notes:
/// - The class is `@MainActor`, but the Firestore stream runs in a background Task.
///   We jump to the main actor only when mutating `@Published` state.
@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    // MARK: - Published UI state

    /// The current list of favorites shown in the UI.
    @Published var favoriteMovies: [Movie] = []

    // MARK: - Dependencies

    /// Firestore repository for favorites (DI-friendly, default provided).
    private let repository: FirestoreFavoritesRepository

    /// Auth wrapper to get/create a user (anonymous if needed).
    private let authService: FirebaseAuthService

    /// Holds the live listener Task so we can cancel it when the view goes away.
    private var favoritesTask: Task<Void, Never>?

    // MARK: - Init / Deinit

    /// Create a ViewModel with injectable dependencies.
    /// Defaults keep app code simple while remaining testable.
    init(
        repository: FirestoreFavoritesRepository = .init(),
        authService: FirebaseAuthService = .init()
    ) {
        self.repository = repository
        self.authService = authService
    }

    /// Ensure we don’t leak the stream if the VM is deallocated.
    deinit {
        favoritesTask?.cancel()
    }

    // MARK: - Live stream

    /// Start a **real-time** listener for the signed-in user’s favorites.
    /// Safe to call from `.task {}` in a view. Calling again will cancel and restart.
    func startFavoritesListener() async {
        // Avoid duplicate listeners
        favoritesTask?.cancel()

        do {
            // Ensure we have a user (anonymous if necessary)
            let uid = try await authService.isLoggedIn()

            // Run the Firestore stream off the main actor
            favoritesTask = Task {
                for await movies in repository.favoritesStream(for: uid) {
                    // Hop to main actor only to publish state
                    await MainActor.run {
                        self.favoriteMovies = movies
                    }
                }
            }
        } catch {
            print("Faithless: Could not start favorites listener: \(error)")
        }
    }

    /// Stop listening to updates (call in `onDisappear` or when tab changes).
    func stopFavoritesListener() {
        favoritesTask?.cancel()
        favoritesTask = nil
    }

    // MARK: - User actions

    /// Optimistically toggle a movie as favorite.
    /// - If it exists locally, remove it (and delete remotely).
    /// - Otherwise add it locally and upsert remotely.
    func toggleFavorite(movie: Movie) async {
        do {
            let uid = try await authService.isLoggedIn()

            if favoriteMovies.contains(where: { $0.id == movie.id }) {
                try await repository.removeFavorite(id: movie.id, for: uid)
                // Optimistic local update; stream will reconcile if needed
                favoriteMovies.removeAll { $0.id == movie.id }
            } else {
                try await repository.addFavorite(movie: movie, for: uid)
                favoriteMovies.insert(movie, at: 0)
            }
        } catch {
            print("Failed to toggle favorite:", error)
        }
    }
}
