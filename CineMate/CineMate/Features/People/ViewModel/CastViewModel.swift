//
//  CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import Foundation

/// ViewModel responsible for loading and caching movie cast & crew data.
@MainActor
final class CastViewModel: ObservableObject {
    @Published var cast: [CastMember] = []
    @Published var crew: [CrewMember] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var activeMovieID: Int?

    internal let repository: MovieProtocol

    private var cache: [Int: MovieCredits] = [:]
    private var inFlightRequests: Set<Int> = []
    private var requestedMovieID: Int?

    init(repository: MovieProtocol) {
        self.repository = repository
    }

    /// Loads the cast and crew for the given movie ID.
    /// - Parameter movieId: The TMDB ID of the movie.
    ///
    /// Uses an in-memory cache to avoid redundant API calls.
    /// If a request is already in flight for the same movie ID, it will be skipped.
    func loadCredits(for movieId: Int) async {
        requestedMovieID = movieId

        if let cached = cache[movieId] {
            apply(credits: cached, for: movieId)
            return
        }

        if activeMovieID != movieId {
            cast = []
            crew = []
        }

        guard !inFlightRequests.contains(movieId) else { return }
        inFlightRequests.insert(movieId)

        isLoading = true
        defer {
            inFlightRequests.remove(movieId)
            if requestedMovieID == movieId {
                isLoading = false
            }
        }

        do {
            let credits = try await repository.fetchMovieCredits(for: movieId)
            cache[movieId] = credits

            guard requestedMovieID == movieId else { return }
            apply(credits: credits, for: movieId)
        } catch {
            guard requestedMovieID == movieId else { return }
            activeMovieID = movieId
            cast = []
            crew = []
            errorMessage = error.localizedDescription
        }
    }

    var credits: MovieCredits? {
        guard let activeMovieID else { return nil }
        return MovieCredits(id: activeMovieID, cast: cast, crew: crew)
    }

    private func apply(credits: MovieCredits, for movieId: Int) {
        activeMovieID = movieId
        cast = credits.cast
        crew = credits.crew
        errorMessage = nil
        isLoading = false
    }
}
