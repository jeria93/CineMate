//
//  PersonViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

/// ViewModel that loads and exposes person-related data (details, external IDs, filmography)
/// for use in SwiftUI views.
///
/// Features:
/// - In-memory caching of fetched data (per personId) to avoid repeated API calls.
/// - In-flight guards to prevent firing the same request concurrently.
/// - Simple favorite-cast toggling to support UI actions.
///
/// Threading: Annotated with `@MainActor`, so all published state changes happen on the main thread.
@MainActor
final class PersonViewModel: ObservableObject {

    // MARK: - Published State

    @Published var personDetail: PersonDetail?
    @Published var personExternalIDs: PersonExternalIDs?
    @Published var personMovies: [PersonMovieCredit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteCastIds: Set<Int> = []

    // MARK: - Dependencies

    /// Repository abstraction that performs the actual API calls.
    private let repository: MovieProtocol

    // MARK: - Caches

    /// Cache for detail + external IDs, keyed by personId.
    /// Tuple keeps related payloads together to avoid multiple lookups.
    private var detailCache: [Int: (detail: PersonDetail, external: PersonExternalIDs?)] = [:]

    /// Cache for movie credits (filmography), keyed by personId.
    private var creditsCache: [Int: [PersonMovieCredit]] = [:]
    private var runningTasks: [Int: [Task<Void, Never>]] = [:]

    // MARK: - In-flight Guards

    /// Set of personIds currently being fetched for detail/external IDs.
    private var detailInFlight: Set<Int> = []

    /// Set of personIds currently being fetched for credits.
    private var creditsInFlight: Set<Int> = []

    // MARK: - Init

    /// Initializes a new `PersonViewModel`.
    /// - Parameter repository: Concrete implementation of `MovieProtocol`.
    init(repository: MovieProtocol) {
        self.repository = repository
    }

    // MARK: - Favorites

    /// Toggles a person (by cast id) in/out of the favorites set.
    /// - Parameter id: The cast member's TMDB id.
    func toggleFavoriteCast(id: Int) {
        if favoriteCastIds.contains(id) {
            favoriteCastIds.remove(id)
        } else {
            favoriteCastIds.insert(id)
        }
    }

    /// Checks whether the given cast id is marked as favorite.
    /// - Parameter id: The cast member's TMDB id.
    func isFavoriteCast(id: Int) -> Bool {
        favoriteCastIds.contains(id)
    }

    // MARK: - Loaders

    /// Loads `PersonDetail` and `PersonExternalIDs` for a given person.
    ///
    /// Flow:
    /// 1. Return immediately if cached.
    /// 2. Skip if a request for this `personId` is already in-flight.
    /// 3. Otherwise request both endpoints in parallel, cache & publish.
    ///
    /// - Parameter personId: TMDB person id.
    func loadPersonDetail(for personId: Int) async {
        if let cached = detailCache[personId] {
            personDetail      = cached.detail
            personExternalIDs = cached.external
            errorMessage      = nil
            isLoading         = false
            return
        }

        // in-flight guard
        guard !detailInFlight.contains(personId) else { return }
        detailInFlight.insert(personId)

        isLoading = true
        defer {
            isLoading = false
            detailInFlight.remove(personId)
        }

        // network calls wrapped in a Task (for cancellation support)
        let task = Task { [unowned self] in
            do {
                async let detail   = repository.fetchPersonDetail(for: personId)
                async let external = repository.fetchPersonExternalIDs(for: personId)
                let d  = try await detail
                let ex = try await external

                detailCache[personId] = (d, ex)
                personDetail          = d
                personExternalIDs     = ex
                errorMessage          = nil
            } catch is CancellationError {
                // silently cancelled
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        runningTasks[personId, default: []].append(task)
        _ = await task.value
    }

    /// Loads the movie credits (filmography) for a given person.
    ///
    /// Flow:
    /// 1. Return cached list if present.
    /// 2. Skip if a fetch for this `personId` is already running.
    /// 3. Otherwise fetch, cache, and publish.
    ///
    /// - Parameter personId: TMDB person id.
    func loadPersonMovieCredits(for personId: Int) async {
        // Cache hit – stop spinner early
        if let cached = creditsCache[personId] {
            personMovies = cached
            isLoading    = false
            return
        }

        guard !creditsInFlight.contains(personId) else { return }
        creditsInFlight.insert(personId)

        isLoading = true
        defer {
            isLoading = false
            creditsInFlight.remove(personId)
        }

        let task = Task { [unowned self] in
            do {
                let credits = try await repository.fetchPersonMovieCredits(for: personId)
                creditsCache[personId] = credits
                personMovies = credits
            } catch is CancellationError {
                // silently cancelled
            } catch {
                print("Credits error: \(error)")
            }
        }
        runningTasks[personId, default: []].append(task)
        _ = await task.value
    }

    /// Cancels any ongoing tasks for the given person and clears temporary state.
    /// - Parameter id: TMDB person id.
    func cancelOngoingTasks(for id: Int) {
        runningTasks[id]?.forEach { $0.cancel() }
        runningTasks[id] = nil
        isLoading = false
    }

    // MARK: - Internal implementations (mirrors above, used if needed)

    private func _loadPersonDetailImpl(_ personId: Int) async {
        // NOTE: same logic as loadPersonDetail, just structured differently
        if let cached = detailCache[personId] {
            personDetail      = cached.detail
            personExternalIDs = cached.external
            errorMessage      = nil
            return
        }
        guard !detailInFlight.contains(personId) else { return }
        detailInFlight.insert(personId)

        isLoading = true
        defer {
            isLoading = false
            detailInFlight.remove(personId)
        }

        do {
            async let detail   = repository.fetchPersonDetail(for: personId)
            async let external = repository.fetchPersonExternalIDs(for: personId)

            let d  = try await detail
            let ex = try await external

            detailCache[personId] = (d, ex)
            personDetail          = d
            personExternalIDs     = ex
            errorMessage          = nil
        } catch is CancellationError {
            // silently cancelled
        } catch {
            personDetail      = nil
            personExternalIDs = nil
            errorMessage      = error.localizedDescription
        }
    }

    private func _loadPersonMovieCreditsImpl(_ personId: Int) async {
        if let cached = creditsCache[personId] {
            personMovies = cached
            return
        }
        guard !creditsInFlight.contains(personId) else { return }
        creditsInFlight.insert(personId)

        do {
            let credits = try await repository.fetchPersonMovieCredits(for: personId)
            creditsCache[personId] = credits
            personMovies = credits
        } catch is CancellationError {
            // silently cancelled
        } catch {
            personMovies = []
            print("Failed to load movie credits for person: \(error.localizedDescription)")
        }
        creditsInFlight.remove(personId)
    }
}

// MARK: - Computed Helpers

extension PersonViewModel {
    /// Top 5 most popular movies used for the "Known For" section.
    var knownForMovies: [PersonMovieCredit] {
        personMovies
            .filter { $0.popularity != nil }
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            .prefix(5)
            .map { $0 }
    }
}

extension PersonViewModel {
    /// Returns cached `PersonDetail` if already fetched.
    func person(by id: Int) -> PersonDetail? {
        detailCache[id]?.detail
    }
}

extension PersonViewModel {
    /// Clears state before loading a new person to avoid showing stale data.
    func resetForNewPerson() {
        personDetail      = nil
        personExternalIDs = nil
        personMovies      = []
        errorMessage      = nil
    }
}

extension PersonViewModel {
    /// Returns true if movie credits are already cached for the person.
    func hasCredits(for id: Int) -> Bool {
        creditsCache[id] != nil
    }
}
