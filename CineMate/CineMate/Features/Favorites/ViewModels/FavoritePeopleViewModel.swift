//
//  FavoritePeopleViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// ViewModel managing the user's **favorite people**.
/// Starts/stops a Firestore real-time stream, exposes UI state,
/// and handles add/remove actions. Skips work in Xcode previews.
@MainActor
final class FavoritePeopleViewModel: ObservableObject {

    /// Current list of favorited people (read-only from outside).
    @Published private(set) var favorites: [PersonRef] = []

    /// User-facing error message (nil when everything is OK).
    @Published var errorMessage: String?

    /// Indicates whether the initial load is in progress.
    @Published var isLoading = false

    // MARK: - Dependencies

    /// Firebase Auth service used to resolve the current user.
    private let authService: FirebaseAuthService

    /// Repository for reading/writing favorites in Firestore.
    private let repository: FirestoreFavoritePeopleRepository

    // MARK: - Runtime flags/tasks

    /// The background task that hosts the Firestore stream.
    private var streamTask: Task<Void, Never>?

    /// Prevents starting multiple listeners at the same time.
    private var isListening = false

    /// Tracks if at least one successful load has completed.
    private var hasLoadedOnce = false

    /// Creates a new instance with injectable dependencies.
    /// - Parameters:
    ///   - authService: Auth service (defaults to production).
    ///   - repository: Firestore repository (defaults to production).
    init(
        authService: FirebaseAuthService = .init(),
        repository: FirestoreFavoritePeopleRepository = .init()
    ) {
        self.authService = authService
        self.repository = repository
    }

    /// Starts the Firestore listener if not already running.
    /// Skips entirely in Xcode previews to keep them fast/offline.
    func startFavoritesListenerIfNeeded() async {
        // Skip work in previews (keeps Previews fast and offline)
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard !isListening else { return }

        isListening = true
        errorMessage = nil
        if !hasLoadedOnce { isLoading = true }

        // Capture repository strongly and avoid self where possible
        do {
            let uid = try await authService.isLoggedIn()

            streamTask?.cancel()
            let repo = repository
            streamTask = Task { [weak self] in
                for await people in repo.favoritePeopleStream(uid: uid) {
                    await MainActor.run {
                        self?.favorites = people
                        self?.isLoading = false
                        self?.hasLoadedOnce = true
                        self?.errorMessage = nil
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isListening = false
        }
    }

    /// Stops the active Firestore listener task (if any).
    func stopFavoritesListenerIfNeeded() {
        guard !ProcessInfo.processInfo.isPreview else { return }
        streamTask?.cancel()
        streamTask = nil
        isListening = false
    }

    /// Checks if a given person ID is already favorited.
    /// - Parameter id: TMDB person ID.
    /// - Returns: `true` if the person exists in `favorites`.
    func isFavorite(id: Int) -> Bool {
        favorites.contains { $0.id == id }
    }

    /// Toggles a person as a favorite for the current user.
    /// Performs an optimistic UI update and falls back to the stream.
    /// - Parameter person: The person to add/remove.
    func toggleFavorite(person: PersonRef) async {
        do {
            let uid = try await authService.isLoggedIn()
            if isFavorite(id: person.id) {
                try await repository.removeFavorite(id: person.id, uid: uid)
                favorites.removeAll { $0.id == person.id }
            } else {
                try await repository.addFavorite(person: person, uid: uid)
                favorites.insert(person, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// Preview-only helper to inject state into the ViewModel
/// without hitting Firestore or changing production paths.
extension FavoritePeopleViewModel {

    /// Sets preview data for `favorites` and clears errors.
    /// - Parameter favorites: The list to present in previews.
    func _setPreviewFavorites(_ favorites: [PersonRef]) {
        self.favorites = favorites
        self.errorMessage = nil
    }
}
