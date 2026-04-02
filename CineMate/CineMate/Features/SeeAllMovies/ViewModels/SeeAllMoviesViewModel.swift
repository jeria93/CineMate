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
    @Published var errorMessage: String?

    var hasError: Bool { errorMessage != nil }

    private enum CacheKey: Hashable {
        case discover(DiscoverFilter)
        case category(MovieCategory)
        case nowPlaying
    }

    private struct PageFetchResult {
        let movies: [Movie]
        let totalPages: Int
    }

    private let repository: MovieProtocol
    private let source: SeeAllMoviesSource

    let pagination = PaginationManager()

    private var movieCache: [CacheKey: [Int: [Movie]]] = [:]
    private var totalPagesCache: [CacheKey: Int] = [:]
    private var loadedMovieIDs = Set<Int>()
    private var fetchTask: Task<Void, Never>?

    init(repository: MovieProtocol, source: SeeAllMoviesSource) {
        self.repository = repository
        self.source = source
    }

    func loadInitialMovies() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard movies.isEmpty else { return }
        await fetchNextPage()
    }

    func fetchNextPage() async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard fetchTask == nil else {
            await fetchTask?.value
            return
        }

        errorMessage = nil

        let key = currentCacheKey
        let isFirstLoad = movies.isEmpty && pagination.state.currentPage == 1
        let pageToFetch = isFirstLoad ? 1 : pagination.state.currentPage + 1

        if let cached = movieCache[key]?[pageToFetch] {
            appendUniqueMovies(cached)
            let cachedTotalPages = totalPagesForCachedPage(
                key: key,
                page: pageToFetch,
                cachedMovies: cached
            )
            pagination.finishFetching(page: pageToFetch, totalPages: cachedTotalPages)
            return
        }

        if !isFirstLoad {
            guard pagination.startFetchingNextPage() else { return }
        }

        let task = Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            defer {
                self.isLoading = false
                self.fetchTask = nil
            }

            do {
                let pageResult = try await self.fetchPage(pageToFetch)
                self.movieCache[key, default: [:]][pageToFetch] = pageResult.movies
                self.totalPagesCache[key] = pageResult.totalPages
                self.appendUniqueMovies(pageResult.movies)
                self.pagination.finishFetching(page: pageToFetch, totalPages: pageResult.totalPages)
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = error.localizedDescription
                }
                self.pagination.cancelFetching()
            }
        }

        fetchTask = task
        await task.value
    }

    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard
            let last = movies.last,
            last.id == currentItem.id,
            pagination.hasMorePages
        else { return }
        await fetchNextPage()
    }

    func clearCache() {
        fetchTask?.cancel()
        fetchTask = nil
        movies.removeAll()
        loadedMovieIDs.removeAll()
        movieCache.removeAll()
        totalPagesCache.removeAll()
        pagination.reset()
        errorMessage = nil
    }

    private var currentCacheKey: CacheKey {
        switch source {
        case .discover(let filter):
            var normalizedFilter = filter
            normalizedFilter.page = 0
            return .discover(normalizedFilter)
        case .category(let category):
            return .category(category)
        case .nowPlaying:
            return .nowPlaying
        }
    }

    private func fetchPage(_ page: Int) async throws -> PageFetchResult {
        switch source {
        case .discover(let filter):
            let filterForPage = filter.withPage(page)
            let fetchedMovies = try await repository.discoverMovies(filters: filterForPage.queryItems)

            // Discover responses can be inconsistent across filters,
            // so continue until an empty page is returned.
            let derivedTotalPages = page + (fetchedMovies.isEmpty ? 0 : 1)
            return PageFetchResult(movies: fetchedMovies, totalPages: derivedTotalPages)

        case .category(let category):
            let result = try await repository.fetchMovies(category: category, page: page)
            return PageFetchResult(
                movies: result.results,
                totalPages: max(page, result.totalPages)
            )

        case .nowPlaying:
            let result = try await repository.fetchNowPlayingMovies(page: page, region: nil)
            return PageFetchResult(
                movies: result.results,
                totalPages: max(page, result.totalPages)
            )
        }
    }

    private func totalPagesForCachedPage(key: CacheKey, page: Int, cachedMovies: [Movie]) -> Int {
        if let cachedTotalPages = totalPagesCache[key] {
            return max(page, cachedTotalPages)
        }

        switch key {
        case .discover, .category:
            return page + (cachedMovies.isEmpty ? 0 : 1)
        case .nowPlaying:
            return page + (cachedMovies.isEmpty ? 0 : 1)
        }
    }

    private func appendUniqueMovies(_ newMovies: [Movie]) {
        for movie in newMovies where !loadedMovieIDs.contains(movie.id) {
            movies.append(movie)
            loadedMovieIDs.insert(movie.id)
        }
    }
}
