//
//  PersonViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

@MainActor
final class PersonViewModel: ObservableObject {
    @Published var personDetail: PersonDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var personMovies: [Movie] = []
//Refactor with helper methods -> less code
    private let repository: MovieProtocol

    init(repository: MovieProtocol) {
        self.repository = repository
    }

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
