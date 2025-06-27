//
//  PersonViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

@MainActor
final class PersonViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var personDetail: PersonDetail?
    @Published var personMovies: [PersonMovieCredit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteCastIds: Set<Int> = []

    // MARK: - Dependencies
    private let repository: MovieProtocol

    // MARK: - Init
    init(repository: MovieProtocol) {
        self.repository = repository
    }

    // MARK: - Favorites
    func toggleFavoriteCast(id: Int) {
        if favoriteCastIds.contains(id) {
            favoriteCastIds.remove(id)
        } else {
            favoriteCastIds.insert(id)
        }
    }

    func isFavoriteCast(id: Int) -> Bool {
        favoriteCastIds.contains(id)
    }

    // MARK: - Loaders
    func loadPersonDetail(for personId: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            personDetail = try await repository.fetchPersonDetail(for: personId)
            errorMessage = nil
        } catch {
            personDetail = nil
            errorMessage = error.localizedDescription
        }
    }

    func loadPersonMovieCredits(for personId: Int) async {
        do {
            personMovies = try await repository.fetchPersonMovieCredits(for: personId)
        } catch {
            print("Failed to load movies for person: \(error.localizedDescription)")
        }
    }
}
