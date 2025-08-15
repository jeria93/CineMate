//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// Owns UI state and Firestore streaming for a user's **favorite movies**.
/// Runs on the main actor; skips network work during Xcode Previews.
@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    /// Current favorite movies for rendering.
    @Published var favoriteMovies: [Movie] = []

    /// True while the initial load is in progress.
    @Published var isLoading = false

    /// User-facing error message or `nil` when OK.
    @Published var errorMessage: String?

    /// Firestore repository used for reads/writes.
    private let repository: FirestoreFavoritesRepository

    /// Auth service used to obtain a UID.
    private let authService: FirebaseAuthService

    /// Active Firestore listener task.
    private var favoritesTask: Task<Void, Never>?

    /// Tracks if at least one successful load completed.
    private var hasLoadedOnce = false

    /// Prevents multiple listeners from starting.
    private var isListening = false

    /// Designated initializer with injectable dependencies.
    init(
        repository: FirestoreFavoritesRepository = .init(),
        authService: FirebaseAuthService = .init()
    ) {
        self.repository = repository
        self.authService = authService
    }

    deinit { favoritesTask?.cancel() }

    /// Starts the Firestore stream (no-op in previews).
    func startFavoritesListenerIfNeeded() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard !isListening else { return }

        isListening = true
        errorMessage = nil
        if !hasLoadedOnce { isLoading = true }

        do {
            let uid = try await authService.isLoggedIn()
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

    /// Stops the active stream without clearing current UI state.
    func stopFavoritesListenerIfNeeded() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        favoritesTask?.cancel()
        favoritesTask = nil
        isListening = false
    }

    /// Optimistically toggles a movie as favorite for the current user.
    /// Falls back to stream updates if a conflict happens.
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

/// Static preview builder – never touches Firebase.
/// Produces deterministic, fully local state for SwiftUI previews.
@MainActor
extension FavoriteMoviesViewModel {

    /// Creates a VM seeded with static data for previews.
    /// - Parameter movies: List to expose to the UI.
    static func preview(with movies: [Movie] = []) -> FavoriteMoviesViewModel {
        let vm = FavoriteMoviesViewModel()
        vm.favoriteMovies = movies
        vm.isLoading = false
        vm.errorMessage = nil
        return vm
    }
}
