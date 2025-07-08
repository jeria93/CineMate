//
//  SearchViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet { debounceSearch() }
    }

    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var error: SearchError?
    @Published var validationMessage: String?
    @Published var lastValidQuery: String?
    @Published var trimmedQuery: String = ""

    private let repository: MovieProtocol
    private var debounceTask: Task<Void, Never>?

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    private func debounceSearch() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            await self?.performSearchIfNeeded()
        }
    }

    private func performSearchIfNeeded() async {
        let result = SearchValidator.validate(query)
        trimmedQuery = result.trimmed ?? ""
        validationMessage = result.message

        if result.isValid, let trimmed = result.trimmed {
            await performSearch(for: trimmed)
        } else {
            clearState()
        }
    }

    func search(_ query: String) async {
        let result = SearchValidator.validate(query)

        guard result.isValid, let trimmed = result.trimmed else {
            return
        }

        lastValidQuery = trimmed
        await performSearch(for: trimmed)
    }

    private func performSearch(for query: String) async {
        isLoading = true
        error = nil

        do {
            results = try await repository.searchMovies(query: query)
            if results.isEmpty {
                error = .noResults
            }
        } catch {
            self.error = .networkFailure
            results = []
        }

        isLoading = false
    }

    private func clearState() {
        results = []
        error = nil
        isLoading = false
    }
}
