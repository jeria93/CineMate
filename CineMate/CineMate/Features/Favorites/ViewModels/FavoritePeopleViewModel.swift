//
//  FavoritePeopleViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Owns UI state for **favorite people**.
/// Supports production mode (Firestore stream) and static preview mode (local only).
@MainActor
final class FavoritePeopleViewModel: ObservableObject {

    enum ContentState: Equatable {
        case loading
        case empty
        case content
        case error(String)
    }

    // MARK: - UI state

    /// Current favorite people for rendering.
    @Published private(set) var favorites: [PersonRef] = []

    /// IDs currently being written to Firestore.
    @Published private(set) var pendingPersonIDs: Set<Int> = []

    /// User-facing error message or `nil` when OK.
    @Published var errorMessage: String?

    /// True while the initial load for current auth session is in progress.
    @Published var isLoading = false

    /// Derived UI state used by views for clear loading/error/empty/content separation.
    var contentState: ContentState {
        if isLoading, favorites.isEmpty {
            return .loading
        }

        if let errorMessage, favorites.isEmpty {
            return .error(errorMessage)
        }

        return favorites.isEmpty ? .empty : .content
    }

    /// Optional message shown while existing content is still available.
    var inlineErrorMessage: String? {
        favorites.isEmpty ? nil : errorMessage
    }

    // MARK: - Mode & dependencies

    private enum Mode {
        case production
        case staticPreview
    }

    private let mode: Mode
    private let auth: FirebaseAuthService?
    private let repo: FirestoreFavoritePeopleRepository?

    // MARK: - Runtime

    /// Active Firestore listener task.
    private var streamTask: Task<Void, Never>?

    /// Current user uid tied to the active listener.
    private var listenerUID: String?

    // MARK: - Init (production)

    /// Designated initializer for production mode.
    /// - Parameters:
    ///   - auth: Auth service.
    ///   - repository: Firestore repository.
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
        self.isLoading = false
        self.errorMessage = nil
    }

    deinit { streamTask?.cancel() }

    // MARK: - Listener lifecycle

    /// Binds favorites listener lifecycle to auth state.
    /// - Parameter uid: Current signed in uid, or `nil` when signed out.
    func syncAuthState(uid: String?) {
        guard mode == .production else { return }

        if uid == listenerUID, streamTask != nil {
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

    /// Stops the Firestore stream (no-op in static preview mode).
    /// - Parameter keepCurrentState: When true, keeps existing content/error in memory.
    func stopFavoritesListenerIfNeeded(keepCurrentState: Bool = true) {
        guard mode == .production else { return }

        streamTask?.cancel()
        streamTask = nil
        listenerUID = nil
        pendingPersonIDs.removeAll()
        isLoading = false

        guard !keepCurrentState else { return }
        favorites = []
        errorMessage = nil
    }

    /// Retries listener for the currently active session uid.
    func retryListener() {
        guard mode == .production else { return }
        syncAuthState(uid: listenerUID ?? auth?.currentUserID)
    }

    private func startFavoritesListener(for uid: String) {
        guard mode == .production else { return }
        guard streamTask == nil else { return }
        guard let repo else { return }

        listenerUID = uid
        errorMessage = nil
        if favorites.isEmpty {
            isLoading = true
        }

        streamTask = Task { [weak self, repo] in
            guard let self else { return }

            do {
                for try await people in repo.favoritePeopleStream(uid: uid) {
                    if Task.isCancelled { break }
                    self.applySnapshot(people, for: uid)
                }
            } catch is CancellationError {
                // Cancellation is expected when listener stops.
            } catch {
                self.handleStreamError(error, for: uid)
            }

            self.handleStreamTermination(for: uid)
        }
    }

    // MARK: - Public API

    /// Returns true if the given person is already a favorite.
    /// - Parameter id: TMDB person ID.
    func isFavorite(id: Int) -> Bool {
        favorites.contains { $0.id == id }
    }

    /// Returns true if a toggle write is currently in-flight for this person ID.
    func isToggleInFlight(id: Int) -> Bool {
        pendingPersonIDs.contains(id)
    }

    /// Toggles a person as favorite.
    /// - Optimistic local update in previews; Firestore in production.
    func toggleFavorite(person: PersonRef) async {
        switch mode {
        case .staticPreview:
            toggleLocally(person: person)

        case .production:
            guard let auth, let repo else { return }
            guard let uid = listenerUID ?? auth.currentUserID else {
                errorMessage = "Sign in to save favorites."
                return
            }

            guard !pendingPersonIDs.contains(person.id) else { return }
            pendingPersonIDs.insert(person.id)
            errorMessage = nil

            let wasFavorite = isFavorite(id: person.id)
            let previousIndex = favorites.firstIndex { $0.id == person.id }

            applyOptimisticToggle(person: person, wasFavorite: wasFavorite)

            do {
                if wasFavorite {
                    try await repo.removeFavorite(id: person.id, uid: uid)
                } else {
                    try await repo.addFavorite(person: person, uid: uid)
                }
            } catch {
                rollbackOptimisticToggle(
                    person: person,
                    wasFavorite: wasFavorite,
                    previousIndex: previousIndex
                )
                errorMessage = error.localizedDescription
            }

            pendingPersonIDs.remove(person.id)
        }
    }

    // MARK: - Stream handling

    private func applySnapshot(_ people: [PersonRef], for uid: String) {
        guard listenerUID == uid else { return }

        favorites = people.removingDuplicateIDs()
        pendingPersonIDs.subtract(people.map(\.id))
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
        streamTask = nil
        isLoading = false
    }

    // MARK: - Local mutation helpers

    private func applyOptimisticToggle(person: PersonRef, wasFavorite: Bool) {
        if wasFavorite {
            favorites.removeAll { $0.id == person.id }
            return
        }

        favorites.removeAll { $0.id == person.id }
        favorites.insert(person, at: 0)
    }

    private func rollbackOptimisticToggle(person: PersonRef, wasFavorite: Bool, previousIndex: Int?) {
        if wasFavorite {
            guard !isFavorite(id: person.id) else { return }
            let restoredIndex = min(previousIndex ?? 0, favorites.count)
            favorites.insert(person, at: restoredIndex)
            return
        }

        favorites.removeAll { $0.id == person.id }
    }

    private func toggleLocally(person: PersonRef) {
        let wasFavorite = isFavorite(id: person.id)
        applyOptimisticToggle(person: person, wasFavorite: wasFavorite)
    }

    private func clearForSignedOutState() {
        favorites = []
        pendingPersonIDs.removeAll()
        isLoading = false
        errorMessage = nil
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
