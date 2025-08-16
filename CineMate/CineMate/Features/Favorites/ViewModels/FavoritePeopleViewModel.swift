//
//  FavoritePeopleViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Owns UI state for **favorite people**. Supports two modes:
/// 1) production (Firestore stream) and 2) static previews (local only).
@MainActor
final class FavoritePeopleViewModel: ObservableObject {

    // MARK: - UI state

    /// Current favorite people for rendering.
    @Published private(set) var favorites: [PersonRef] = []

    /// User-facing error message or `nil` when OK.
    @Published var errorMessage: String?

    /// True while the initial load is in progress.
    @Published var isLoading = false

    // MARK: - Mode & dependencies

    /// Runtime mode: `.production` (Firebase) or `.staticPreview` (local).
    private enum Mode { case production, staticPreview }

    /// Current runtime mode.
    private let mode: Mode

    /// Auth service (production mode only).
    private let auth: FirebaseAuthService?

    /// Firestore repository (production mode only).
    private let repo: FirestoreFavoritePeopleRepository?

    // MARK: - Runtime

    /// Active Firestore listener task.
    private var streamTask: Task<Void, Never>?

    /// Prevents multiple listeners from starting.
    private var isListening = false

    /// Tracks if at least one successful load completed.
    private var hasLoadedOnce = false

    // MARK: - Init (production)

    /// Designated initializer for production mode.
    /// - Parameters:
    ///   - auth: Auth service.
    ///   - repo: Firestore repository.
    init(auth: FirebaseAuthService, repo: FirestoreFavoritePeopleRepository) {
        self.auth = auth
        self.repo = repo
        self.mode = .production
    }

    /// Convenience default for app code (`FavoritePeopleViewModel()`).
    convenience init() {
        self.init(auth: FirebaseAuthService(), repo: FirestoreFavoritePeopleRepository())
    }

    // MARK: - Init (static preview)

    /// Static preview initializer – no Firebase, no networking.
    /// - Parameter people: Seeded favorites for design-time UI.
    init(static people: [PersonRef]) {
        self.auth = nil
        self.repo = nil
        self.mode = .staticPreview
        self.favorites = people
    }

    deinit { streamTask?.cancel() }

    // MARK: - Public API

    /// Starts the Firestore stream (no-op in static preview mode).
    func startFavoritesListenerIfNeeded() async {
        guard mode == .production else { return }
        guard !isListening else { return }
        isListening = true
        errorMessage = nil
        if !hasLoadedOnce { isLoading = true }

        do {
            guard let auth, let repo else { return }
            let uid = try await auth.isLoggedIn()

            streamTask?.cancel()
            streamTask = Task { [weak self] in
                guard let self else { return }
                for await people in repo.favoritePeopleStream(uid: uid) {
                    self.favorites = people
                    self.isLoading = false
                    self.hasLoadedOnce = true
                    self.errorMessage = nil
                }
            }
        } catch {
            isLoading = false
            isListening = false
            errorMessage = error.localizedDescription
        }
    }

    /// Stops the Firestore stream (no-op in static preview mode).
    func stopFavoritesListenerIfNeeded() {
        guard mode == .production else { return }
        streamTask?.cancel()
        streamTask = nil
        isListening = false
    }

    /// Returns true if the given person is already a favorite.
    /// - Parameter id: TMDB person ID.
    func isFavorite(id: Int) -> Bool {
        favorites.contains { $0.id == id }
    }

    /// Toggles a person as favorite.
    /// - Optimistic local update in previews; Firestore in production.
    func toggleFavorite(person: PersonRef) async {
        switch mode {
        case .staticPreview:
            if isFavorite(id: person.id) {
                favorites.removeAll { $0.id == person.id }
            } else {
                favorites.insert(person, at: 0)
            }

        case .production:
            do {
                guard let auth, let repo else { return }
                let uid = try await auth.isLoggedIn()
                if isFavorite(id: person.id) {
                    try await repo.removeFavorite(id: person.id, uid: uid)
                    favorites.removeAll { $0.id == person.id }
                } else {
                    try await repo.addFavorite(person: person, uid: uid)
                    favorites.insert(person, at: 0)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

/// Convenience alias initializer to write `FavoritePeopleViewModel(preview: people)`
/// from preview factories while keeping the static initializer internal.
@MainActor
extension FavoritePeopleViewModel {
    /// Creates a static preview VM with seeded people.
    /// - Parameter people: Favorites to expose to the UI.
    convenience init(preview people: [PersonRef]) {
        self.init(static: people)
    }
}
