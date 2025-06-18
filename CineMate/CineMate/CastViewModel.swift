//
//  CastViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import Foundation

@MainActor
final class CastViewModel: CastViewModelProtocol {
    @Published var cast: [CastMember] = []
    @Published var crew: [CrewMember] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    func loadCredits(for movieId: Int) async {
        await load { try await self.repository.fetchMovieCredits(for: movieId) }
    }

    private func load(_ fetcher: @escaping () async throws -> MovieCredits) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let credits = try await fetcher()
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
