//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation
import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var sections = DiscoverSectionKind.allCases.map {
        DiscoverSectionState(kind: $0, movies: [])
    }
    @Published var isLoading = false
    @Published var error: SearchError?
    @Published var genres: [Genre] = ProcessInfo.processInfo.isPreview ? GenrePreviewData.genres : []
    @Published var selectedGenreId: Int? {
        didSet {
            guard oldValue != selectedGenreId else { return }
            Task { await filterSections() }
        }
    }

    // MARK: - Public Derived State

    var visibleSections: [DiscoverSectionState] {
        sections.filter { !$0.movies.isEmpty }
    }

    var allSectionsAreEmpty: Bool {
        visibleSections.isEmpty
    }

    // MARK: - Private State

    private enum SectionCacheKey: Hashable {
        case allGenres
        case genre(Int)
    }

    private var sectionCache: [SectionCacheKey: [DiscoverSectionState]] = [:]
    private var loadTask: Task<Void, Never>?
    private var inFlightKey: SectionCacheKey?
    private var activeRequestToken = UUID()

    private let repository: MovieProtocol

    // MARK: - Initialization

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository

        if !ProcessInfo.processInfo.isPreview {
            Task { await fetchGenres() }
        }
    }

    // MARK: - Public API

    func fetchAllSections(forceReload: Bool = false) async {
        await loadSections(for: nil, forceReload: forceReload)
    }

    func filterSections() async {
        await loadSections(for: selectedGenreId, forceReload: false)
    }

    func refreshCurrentSelection(forceReload: Bool = false) async {
        await loadSections(for: selectedGenreId, forceReload: forceReload)
    }

    func seeAllFilter(for section: DiscoverSectionKind) -> DiscoverFilter {
        DiscoverFilterProvider.filter(for: section, selectedGenreId: selectedGenreId)
    }

    func applyPreviewSections(_ sectionMovies: [DiscoverSectionKind: [Movie]]) {
        let previewSections = DiscoverSectionKind.allCases.map { kind in
            DiscoverSectionState(kind: kind, movies: sectionMovies[kind] ?? [])
        }
        apply(previewSections)
    }

    // MARK: - Private Loading Pipeline

    private func loadSections(for genreId: Int?, forceReload: Bool) async {
        guard !ProcessInfo.processInfo.isPreview else { return }
        guard SecretManager.hasBearerToken else {
            error = .custom("Missing API token.")
            isLoading = false
            return
        }

        let cacheKey = sectionCacheKey(for: genreId)
        if forceReload {
            sectionCache[cacheKey] = nil
        } else if let cached = sectionCache[cacheKey] {
            error = nil
            isLoading = false
            apply(cached)
            return
        }

        if !forceReload, let loadTask, inFlightKey == cacheKey {
            await loadTask.value
            return
        }

        loadTask?.cancel()

        let requestToken = UUID()
        activeRequestToken = requestToken
        inFlightKey = cacheKey
        error = nil
        isLoading = true

        let task = Task { [weak self] in
            guard let self else { return }

            do {
                let loadedSections = try await self.fetchSectionSnapshot(for: genreId)
                guard !Task.isCancelled else { return }
                self.commitLoadedSections(loadedSections, cacheKey: cacheKey, requestToken: requestToken)
            } catch is CancellationError {
                self.finishLoadingIfActive(requestToken: requestToken)
            } catch {
                guard !Task.isCancelled else { return }
                self.commitLoadError(error, requestToken: requestToken)
            }
        }

        loadTask = task
        await task.value
    }

    private func fetchSectionSnapshot(for genreId: Int?) async throws -> [DiscoverSectionState] {
        async let topRated = fetchMovies(for: .topRated, genreId: genreId)
        async let popular = fetchMovies(for: .popular, genreId: genreId)
        async let nowPlaying = fetchMovies(for: .nowPlaying, genreId: genreId)
        async let trending = fetchMovies(for: .trending, genreId: genreId)
        async let upcoming = fetchMovies(for: .upcoming, genreId: genreId)
        async let horror = fetchMovies(for: .horror, genreId: genreId)

        return [
            DiscoverSectionState(kind: .topRated, movies: try await topRated),
            DiscoverSectionState(kind: .popular, movies: try await popular),
            DiscoverSectionState(kind: .nowPlaying, movies: try await nowPlaying),
            DiscoverSectionState(kind: .trending, movies: try await trending),
            DiscoverSectionState(kind: .upcoming, movies: try await upcoming),
            DiscoverSectionState(kind: .horror, movies: try await horror)
        ]
    }

    private func fetchMovies(for section: DiscoverSectionKind, genreId: Int?) async throws -> [Movie] {
        let filter = DiscoverFilterProvider.filter(for: section, selectedGenreId: genreId)
        return try await repository.discoverMovies(filters: filter.queryItems)
    }

    private func commitLoadedSections(
        _ loadedSections: [DiscoverSectionState],
        cacheKey: SectionCacheKey,
        requestToken: UUID
    ) {
        guard activeRequestToken == requestToken else { return }
        sectionCache[cacheKey] = loadedSections
        error = nil
        isLoading = false
        inFlightKey = nil
        loadTask = nil
        apply(loadedSections)
    }

    private func commitLoadError(_ loadingError: Error, requestToken: UUID) {
        guard activeRequestToken == requestToken else { return }
        error = .custom(loadingError.localizedDescription)
        isLoading = false
        inFlightKey = nil
        loadTask = nil
    }

    private func finishLoadingIfActive(requestToken: UUID) {
        guard activeRequestToken == requestToken else { return }
        isLoading = false
        inFlightKey = nil
        loadTask = nil
    }

    private func sectionCacheKey(for genreId: Int?) -> SectionCacheKey {
        if let genreId {
            return .genre(genreId)
        }
        return .allGenres
    }

    private func apply(_ sections: [DiscoverSectionState]) {
        self.sections = sections
    }

    // MARK: - Genre Loading

    private func fetchGenres() async {
        do {
            genres = try await repository.fetchGenres()
        } catch {
            print("DiscoverViewModel: Failed to load genres:", error)
        }
    }
}
