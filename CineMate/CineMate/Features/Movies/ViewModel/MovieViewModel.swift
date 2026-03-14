//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation
import SwiftUI

/// Owns movie list state: category selection, pagination, list loading and lightweight movie cache.
@MainActor
final class MovieViewModel: ObservableObject {

    // MARK: - Published State

    /// Current list of movies for the selected category.
    @Published var movies: [Movie] = []

    /// Currently selected movie category.
    @Published var selectedCategory: MovieCategory = .popular

    /// Indicates if the first page is currently loading.
    @Published var isLoading = false

    /// Optional error message to display in the UI.
    @Published var errorMessage: String?

    // MARK: - Pagination

    /// Manages page tracking and prevents duplicate next-page fetches.
    let pagination = PaginationManager()

    // MARK: - Dependencies

    private let repository: MovieProtocol

    /// Exposes the underlying repository for downstream view models.
    var underlyingRepository: MovieProtocol { repository }

    // MARK: - Internal State

    /// Tracks IDs already present in `movies` to avoid duplicates across pages.
    private var seenMovieIDs: Set<Int> = []

    /// Current list-fetch task, used for cancellation and race-condition protection.
    private var listTask: Task<Void, Never>?

    // MARK: - Initialization

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - List Loading

    /// Loads movies for the current category with pagination support.
    func loadMovies(page: Int = 1) async {
        listTask?.cancel()

        listTask = Task {
            await runListLoad(page: page)
        }

        await listTask?.value
    }

    private func runListLoad(page: Int) async {
        if page == 1 {
            pagination.reset()
            isLoading = true
            errorMessage = nil
        } else {
            guard pagination.startFetchingNextPage() else { return }
            syncSeenMovieIDsIfNeeded()
        }

        defer {
            if page == 1 {
                isLoading = false
            }
        }

        do {
            let response = try await repository.fetchMovies(category: selectedCategory, page: page)
            guard !Task.isCancelled else { return }

            if page == 1 {
                let unique = response.results.removingDuplicateIDs()
                movies = unique
                seenMovieIDs = Set(unique.map(\.id))
            } else {
                MovieLoaderHelper.appendNewMovies(
                    currentMovies: &movies,
                    newMovies: response.results,
                    seenIDs: &seenMovieIDs
                )
            }

            pagination.finishFetching(page: response.page, totalPages: response.totalPages)
            errorMessage = nil
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription

            if page != 1 {
                pagination.cancelFetching()
            }
        }
    }

    private func syncSeenMovieIDsIfNeeded() {
        guard seenMovieIDs.isEmpty, !movies.isEmpty else { return }
        seenMovieIDs = Set(movies.map(\.id))
    }

    /// Loads the next page if `currentItem` is the last visible item.
    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard let last = movies.last,
              last.id == currentItem.id,
              pagination.hasMorePages else { return }

        await loadMovies(page: pagination.state.currentPage + 1)
    }

    // MARK: - Helpers

    /// Returns a cached movie by ID.
    func movie(by id: Int) -> Movie? {
        movies.first(where: { $0.id == id })
    }

    /// Caches a lightweight movie stub for immediate UI usage.
    func cacheStub(_ stub: Movie) {
        guard !movies.contains(where: { $0.id == stub.id }) else { return }
        movies.append(stub)
        seenMovieIDs.insert(stub.id)
    }
}

/// User-visible state for movie detail loading.
enum MovieDetailScreenState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case failed(String)
}

enum WatchProvidersSectionState: Equatable {
    case idle
    case loading
    case loaded(WatchProviderAvailability)
    case failed(String)
}

/// Owns movie detail state (detail, trailer videos, providers and recommendations).
@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var movieDetail: MovieDetail?
    @Published var recommendedMovies: [Movie] = []
    @Published var watchProvidersState: WatchProvidersSectionState = .idle
    @Published var movieVideos: [MovieVideo] = []
    @Published var state: MovieDetailScreenState = .idle

    private let repository: MovieProtocol

    private var currentMovieID: Int?
    private var inFlightRequests: Set<Int> = []

    private var detailCache: [Int: MovieDetail] = [:]
    private var recommendationsCache: [Int: [Movie]] = [:]
    private var providerCache: [Int: WatchProviderAvailability] = [:]
    private var videoCache: [Int: [MovieVideo]] = [:]

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case let .failed(message) = state {
            return message
        }
        return nil
    }

    var movieStub: Movie? {
        movieDetail?.asMovieStub
    }

    var watchProviderAvailability: WatchProviderAvailability? {
        if case let .loaded(availability) = watchProvidersState {
            return availability
        }
        return nil
    }

    var watchProviderErrorMessage: String? {
        if case let .failed(message) = watchProvidersState {
            return message
        }
        return nil
    }

    var isWatchProvidersLoading: Bool {
        if case .loading = watchProvidersState {
            return true
        }
        return false
    }

    private enum WatchProvidersFetchResult {
        case loaded(WatchProviderAvailability)
        case failed(String)
    }

    /// Loads the movie detail bundle for one movie ID.
    /// Uses in-memory caches and ignores stale responses from older requests.
    func load(movieId: Int) async {
        let previousMovieID = currentMovieID
        currentMovieID = movieId

        if previousMovieID != movieId {
            clearVisibleState()
        }

        applyCachedValues(for: movieId)
        if hasCompleteCache(for: movieId) {
            state = .loaded
            if providerCache[movieId] == nil {
                await loadWatchProviders(for: movieId)
            }
            return
        }

        guard !inFlightRequests.contains(movieId) else { return }
        inFlightRequests.insert(movieId)
        state = .loading
        if providerCache[movieId] == nil {
            watchProvidersState = .loading
        }

        defer { inFlightRequests.remove(movieId) }

        async let detailRequest = repository.fetchMovieDetails(for: movieId)
        async let recommendationsRequest = repository.fetchRecommendedMovies(for: movieId)
        async let providersResult = fetchWatchProvidersResult(for: movieId)
        async let videosRequest = repository.fetchMovieVideos(for: movieId)

        do {
            let detail = try await detailRequest
            let recommendations = deduplicatedRecommendations(
                from: try await recommendationsRequest,
                excluding: movieId
            )
            let videos = try await videosRequest
            let providerResult = await providersResult

            guard currentMovieID == movieId else { return }

            detailCache[movieId] = detail
            recommendationsCache[movieId] = recommendations
            videoCache[movieId] = videos

            movieDetail = detail
            recommendedMovies = recommendations
            movieVideos = videos
            applyWatchProvidersResult(providerResult, for: movieId)
            state = .loaded
        } catch {
            guard currentMovieID == movieId else { return }
            clearVisibleState()
            state = .failed(error.localizedDescription)
        }
    }

    private func clearVisibleState() {
        movieDetail = nil
        recommendedMovies = []
        watchProvidersState = .idle
        movieVideos = []
        state = currentMovieID == nil ? .idle : .empty
    }

    private func applyCachedValues(for movieId: Int) {
        if let detail = detailCache[movieId] {
            movieDetail = detail
        }
        if let recommendations = recommendationsCache[movieId] {
            recommendedMovies = recommendations
        }
        if let providers = providerCache[movieId] {
            watchProvidersState = .loaded(providers)
        } else {
            watchProvidersState = .idle
        }
        if let videos = videoCache[movieId] {
            movieVideos = videos
        }
    }

    private func hasCompleteCache(for movieId: Int) -> Bool {
        detailCache[movieId] != nil &&
        recommendationsCache[movieId] != nil &&
        videoCache[movieId] != nil
    }

    private func fetchWatchProvidersResult(for movieId: Int) async -> WatchProvidersFetchResult {
        if let cached = providerCache[movieId] {
            return .loaded(cached)
        }

        do {
            let availability = try await repository.fetchWatchProviders(for: movieId)
            return .loaded(availability)
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    private func loadWatchProviders(for movieId: Int) async {
        guard currentMovieID == movieId else { return }
        watchProvidersState = .loading

        let result = await fetchWatchProvidersResult(for: movieId)
        guard currentMovieID == movieId else { return }
        applyWatchProvidersResult(result, for: movieId)
    }

    private func applyWatchProvidersResult(_ result: WatchProvidersFetchResult, for movieId: Int) {
        switch result {
        case .loaded(let availability):
            providerCache[movieId] = availability
            watchProvidersState = .loaded(availability)
        case .failed(let message):
            watchProvidersState = .failed(message)
        }
    }

    private func deduplicatedRecommendations(from movies: [Movie], excluding movieId: Int) -> [Movie] {
        movies
            .filter { $0.id != movieId }
            .removingDuplicateIDs()
    }
}
