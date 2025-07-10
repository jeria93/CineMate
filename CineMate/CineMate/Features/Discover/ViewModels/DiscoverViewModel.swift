//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var error: SearchError?
    @Published var filters = DiscoverFilter()

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchDiscoverMovies() async {
        guard !ProcessInfo.processInfo.isPreview else {
            print("Skipping network call in preview mode.")
            return
        }

        isLoading = true
        error = nil
        do {
            results = try await repository.discoverMovies(filters: filters.queryItems)
        } catch {
            self.error = .networkFailure
            results = []
        }
        isLoading = false
    }
}
