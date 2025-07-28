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

    internal let repository: MovieProtocol

    private var cache: [Int: MovieCredits] = [:]
    private var inFlightRequests: Set<Int> = []

    init(repository: MovieProtocol) {
        self.repository = repository
    }

    /// Loads the cast and crew for the given movie ID.
    /// - Parameter movieId: The TMDB ID of the movie.
    ///
    /// Uses an in-memory cache to avoid redundant API calls.
    /// If a request is already in flight for the same movie ID, it will be skipped.
    func loadCredits(for movieId: Int) async {
        if let cached = cache[movieId] {
            self.cast = cached.cast
            self.crew = cached.crew
            self.errorMessage = nil
            return
        }

        guard !inFlightRequests.contains(movieId) else { return }
        inFlightRequests.insert(movieId)

        isLoading = true
        defer {
            isLoading = false
            inFlightRequests.remove(movieId)
        }

        do {
            let credits = try await repository.fetchMovieCredits(for: movieId)
            cache[movieId] = credits
            cast = credits.cast
            crew = credits.crew
            errorMessage = nil
        } catch {
            cast = []
            crew = []
            errorMessage = error.localizedDescription
        }
    }
}
