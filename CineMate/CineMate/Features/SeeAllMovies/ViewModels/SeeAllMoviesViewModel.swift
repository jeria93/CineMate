//
//  SeeAllMoviesViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

@MainActor
final class SeeAllMoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String?

    internal let repository: MovieProtocol
    private var filter: DiscoverFilter
    private var currentPage = 1
    private var isFetching = false
    private var loadedMovieIDs = Set<Int>()

    init(repository: MovieProtocol, filter: DiscoverFilter) {
        self.repository = repository
        self.filter = filter
    }

    func loadInitialMovies() async {
        guard movies.isEmpty else { return }
        await fetchMoreMovies()
    }

    func fetchMoreMovies() async {
        guard !isFetching else { return }

        beginFetching()

        do {
            let newMovies = try await repository
                .discoverMovies(filters: currentFilter.queryItems)

            MovieLoaderHelper.appendNewMovies(
                currentMovies: &movies,
                newMovies: newMovies,
                seenIDs: &loadedMovieIDs
            )

            currentPage += 1
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }

        endFetching()
    }
}

// MARK: - Helpers

private extension SeeAllMoviesViewModel {
    var currentFilter: DiscoverFilter {
        var updated = filter
        updated.page = currentPage
        return updated
    }

    private func beginFetching() {
        isFetching = true
        isLoading = true
        hasError = false
    }

    private func endFetching() {
        isFetching = false
        isLoading = false
    }
}
