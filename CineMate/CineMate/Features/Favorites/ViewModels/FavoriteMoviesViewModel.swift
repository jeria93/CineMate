//
//  FavoriteMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

/// Owns UI state and Firestore streaming for a user's **favorite movies**.
/// Supports production mode (Firestore) and static preview mode (local only).
@MainActor
final class FavoriteMoviesViewModel: ObservableObject {

    enum ContentState: Equatable {
        case loading
        case empty
        case content
        case error(String)
    }

    /// Current favorite movies for rendering.
    @Published private(set) var favoriteMovies: [Movie] = []

    /// IDs currently being written to Firestore.
    @Published private(set) var pendingMovieIDs: Set<Int> = []

    /// True while the initial load for the current auth session is in progress.
    @Published var isLoading = false

    /// User-facing error message or `nil` when OK.
    @Published var errorMessage: String?

    /// Derived UI state used by views to clearly separate loading/error/empty/content.
    var contentState: ContentState {
        if isLoading, favoriteMovies.isEmpty {
            return .loading
        }

        if let errorMessage, favoriteMovies.isEmpty {
            return .error(errorMessage)
        }

        return favoriteMovies.isEmpty ? .empty : .content
    }

    /// Optional message that can be shown while content is still available.
    var inlineErrorMessage: String? {
        favoriteMovies.isEmpty ? nil : errorMessage
    }

    // MARK: - Mode & dependencies

    private enum Mode {
        case production
        case staticPreview
    }

    private let mode: Mode
    private let repository: FirestoreFavoritesRepository?
    private let authService: FirebaseAuthService?

    // MARK: - Runtime

    /// Active Firestore listener task.
    private var favoritesTask: Task<Void, Never>?

    /// Current user uid tied to the active listener.
    private var listenerUID: String?

    /// Designated initializer for production mode with injectable dependencies.
    init(
        repository: FirestoreFavoritesRepository = .init(),
        authService: FirebaseAuthService = .init()
    ) {
        self.repository = repository
        self.authService = authService
        self.mode = .production
    }

    /// Static preview initializer – no Firebase dependencies.
    private init(static movies: [Movie]) {
        self.repository = nil
        self.authService = nil
        self.mode = .staticPreview
        self.favoriteMovies = movies
        self.isLoading = false
        self.errorMessage = nil
    }

    deinit { favoritesTask?.cancel() }

    // MARK: - Listener lifecycle

    /// Binds favorites listener lifecycle to auth state.
    /// - Parameter uid: Current signed in uid, or `nil` when signed out.
    func syncAuthState(uid: String?) {
        guard mode == .production else { return }

        if uid == listenerUID, favoritesTask != nil {
            return
        }

        let previousUID = listenerUID
        stopFavoritesListenerIfNeeded(keepCurrentState: uid != nil && uid == previousUID)

        guard let uid else {
            clearForSignedOutState()
            return
        }

        startFavoritesListener(for: uid)
    }

    /// Starts listener if no stream is active for this uid.
    private func startFavoritesListener(for uid: String) {
        guard mode == .production else { return }
        guard favoritesTask == nil else { return }
        guard let repository else { return }

        listenerUID = uid
        errorMessage = nil
        if favoriteMovies.isEmpty {
            isLoading = true
        }

        favoritesTask = Task { [weak self, repository] in
            guard let self else { return }

            do {
                for try await movies in repository.favoritesStream(for: uid) {
                    if Task.isCancelled { break }
                    await self.applySnapshot(movies, for: uid)
                }
            } catch is CancellationError {
                // Cancellation is expected when listener stops.
            } catch {
                await self.handleStreamError(error, for: uid)
            }

            await self.handleStreamTermination(for: uid)
        }
    }

    /// Stops active listener.
    /// - Parameter keepCurrentState: When true, keeps existing content/error in memory.
    func stopFavoritesListenerIfNeeded(keepCurrentState: Bool = true) {
        guard mode == .production else { return }

        favoritesTask?.cancel()
        favoritesTask = nil
        listenerUID = nil
        pendingMovieIDs.removeAll()
        isLoading = false

        guard !keepCurrentState else { return }
        favoriteMovies = []
        errorMessage = nil
    }

    /// Retries listener for the currently active session uid.
    func retryListener() {
        guard mode == .production else { return }
        syncAuthState(uid: listenerUID ?? authService?.currentUserID)
    }

    // MARK: - Favorite actions

    /// Returns true if the given movie ID is currently favorited.
    func isFavorite(id: Int) -> Bool {
        favoriteMovies.contains { $0.id == id }
    }

    /// Returns true if a toggle write is currently in-flight for this movie ID.
    func isToggleInFlight(id: Int) -> Bool {
        pendingMovieIDs.contains(id)
    }

    /// Optimistically toggles a movie as favorite and rolls back on write failure.
    func toggleFavorite(movie: Movie) async {
        switch mode {
        case .staticPreview:
            toggleLocally(movie: movie)

        case .production:
            guard let repository else { return }
            guard let uid = listenerUID ?? authService?.currentUserID else {
                errorMessage = "Sign in to save favorites."
                return
            }

            guard !pendingMovieIDs.contains(movie.id) else { return }
            pendingMovieIDs.insert(movie.id)
            errorMessage = nil

            let wasFavorite = isFavorite(id: movie.id)
            let previousIndex = favoriteMovies.firstIndex { $0.id == movie.id }

            applyOptimisticToggle(movie: movie, wasFavorite: wasFavorite)

            do {
                if wasFavorite {
                    try await repository.removeFavorite(id: movie.id, for: uid)
                } else {
                    try await repository.addFavorite(movie: movie, for: uid)
                }
            } catch {
                rollbackOptimisticToggle(
                    movie: movie,
                    wasFavorite: wasFavorite,
                    previousIndex: previousIndex
                )
                errorMessage = error.localizedDescription
            }

            pendingMovieIDs.remove(movie.id)
        }
    }

    // MARK: - Stream handling

    private func applySnapshot(_ movies: [Movie], for uid: String) {
        guard listenerUID == uid else { return }

        favoriteMovies = movies.removingDuplicateIDs()
        pendingMovieIDs.subtract(movies.map(\.id))
        isLoading = false
        errorMessage = nil
    }

    private func handleStreamError(_ error: Error, for uid: String) {
        guard listenerUID == uid else { return }
        isLoading = false
        errorMessage = error.localizedDescription
    }

    private func handleStreamTermination(for uid: String) {
        guard listenerUID == uid else { return }
        favoritesTask = nil
        isLoading = false
    }

    // MARK: - Local mutation helpers

    private func applyOptimisticToggle(movie: Movie, wasFavorite: Bool) {
        if wasFavorite {
            favoriteMovies.removeAll { $0.id == movie.id }
            return
        }

        favoriteMovies.removeAll { $0.id == movie.id }
        favoriteMovies.insert(movie, at: 0)
    }

    private func rollbackOptimisticToggle(movie: Movie, wasFavorite: Bool, previousIndex: Int?) {
        if wasFavorite {
            guard !isFavorite(id: movie.id) else { return }
            let restoredIndex = min(previousIndex ?? 0, favoriteMovies.count)
            favoriteMovies.insert(movie, at: restoredIndex)
            return
        }

        favoriteMovies.removeAll { $0.id == movie.id }
    }

    private func toggleLocally(movie: Movie) {
        let wasFavorite = isFavorite(id: movie.id)
        applyOptimisticToggle(movie: movie, wasFavorite: wasFavorite)
    }

    private func clearForSignedOutState() {
        favoriteMovies = []
        pendingMovieIDs.removeAll()
        isLoading = false
        errorMessage = nil
    }
}

/// Static preview builder – never touches Firebase.
/// Produces deterministic, fully local state for SwiftUI previews.
@MainActor
extension FavoriteMoviesViewModel {

    /// Creates a VM seeded with static data for previews.
    /// - Parameter movies: List to expose to the UI.
    static func preview(with movies: [Movie] = []) -> FavoriteMoviesViewModel {
        FavoriteMoviesViewModel(static: movies)
    }
}
