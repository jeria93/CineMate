//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }


    func search() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            results = try await repository.searchMovies(query: query)
        } catch {
            errorMessage = "Could not load search results. Try again."
        }

        isLoading = false
    }
}
