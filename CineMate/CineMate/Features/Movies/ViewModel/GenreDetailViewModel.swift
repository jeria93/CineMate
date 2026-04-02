//
//  GenreDetailViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-04-02.
//

import Foundation
import SwiftUI

@MainActor
final class GenreDetailViewModel: ObservableObject {
    enum AllMoviesSort: String, CaseIterable, Identifiable {
        case popular
        case topRated
        case newest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .popular:
                return "Popularity"
            case .topRated:
                return "Rating"
            case .newest:
                return "Newest"
            }
        }

        var sortOption: SortOption {
            switch self {
            case .popular:
                return .popularityDesc
            case .topRated:
                return .voteAverageDesc
            case .newest:
                return .releaseDateDesc
            }
        }
    }

    @Published private(set) var popularMovies: [Movie] = []
    @Published private(set) var topRatedMovies: [Movie] = []
    @Published private(set) var newReleaseMovies: [Movie] = []
    @Published private(set) var allMovies: [Movie] = []

    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false

    @Published private(set) var sectionErrorMessage: String?
    @Published private(set) var listErrorMessage: String?

    @Published var selectedSort: AllMoviesSort = .popular {
        didSet {
            guard oldValue != selectedSort else { return }
            Task { await reloadAllMoviesForCurrentSort() }
        }
    }

    var hasNoContent: Bool {
        !hasHighlights && allMovies.isEmpty
    }

    var primaryErrorMessage: String? {
        listErrorMessage ?? sectionErrorMessage
    }

    private var hasHighlights: Bool {
        !popularMovies.isEmpty || !topRatedMovies.isEmpty || !newReleaseMovies.isEmpty
    }

    private let genreId: Int
    private let repository: MovieProtocol
    private let pagination = PaginationManager()

    private var loadedMovieIDs = Set<Int>()
    private var hasLoadedInitial = false

    private var highlightsTask: Task<Void, Never>?
    private var allMoviesTask: Task<Void, Never>?

    init(genreId: Int, repository: MovieProtocol = MovieRepository()) {
        self.genreId = genreId
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard !hasLoadedInitial else { return }
        await refresh()
    }

    func refresh() async {
        hasLoadedInitial = true
        isLoading = true
        sectionErrorMessage = nil
        listErrorMessage = nil

        await fetchHighlights()
        await reloadAllMoviesForCurrentSort(forceReload: true)

        isLoading = false
    }

    func retryAllMovies() async {
        await reloadAllMoviesForCurrentSort(forceReload: true)
    }

    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard let last = allMovies.last, last.id == currentItem.id else { return }
        await fetchNextAllMoviesPage()
    }

    private func fetchHighlights() async {
        highlightsTask?.cancel()
        highlightsTask = Task { [weak self] in
            guard let self else { return }

            do {
                let snapshot = try await self.fetchHighlightsSnapshot()
                guard !Task.isCancelled else { return }

                self.popularMovies = snapshot.popular.removingDuplicateIDs()
                self.topRatedMovies = snapshot.topRated.removingDuplicateIDs()
                self.newReleaseMovies = snapshot.newReleases.removingDuplicateIDs()
                self.sectionErrorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                self.popularMovies = []
                self.topRatedMovies = []
                self.newReleaseMovies = []
                self.sectionErrorMessage = error.localizedDescription
            }
        }
        await highlightsTask?.value
    }

    private func reloadAllMoviesForCurrentSort(forceReload: Bool = false) async {
        guard hasLoadedInitial || forceReload else { return }

        allMoviesTask?.cancel()
        allMoviesTask = Task { [weak self] in
            guard let self else { return }
            self.resetAllMoviesState()
            await self.fetchNextAllMoviesPage()
        }
        await allMoviesTask?.value
    }

    private func fetchNextAllMoviesPage() async {
        guard !isLoadingMore else { return }

        let isFirstPage = allMovies.isEmpty
        let page = isFirstPage ? 1 : pagination.state.currentPage + 1

        if !isFirstPage {
            guard pagination.startFetchingNextPage() else { return }
        }

        isLoadingMore = true
        listErrorMessage = nil

        defer {
            isLoadingMore = false
        }

        do {
            let filter = allMoviesFilter(page: page)
            let fetchedMovies = try await repository.discoverMovies(filters: filter.queryItems)
            guard !Task.isCancelled else { return }

            let uniqueMovies = fetchedMovies.excluding(alreadySeenIDs: loadedMovieIDs)
            loadedMovieIDs.formUnion(uniqueMovies.map(\.id))
            allMovies.append(contentsOf: uniqueMovies)

            let derivedTotalPages = page + (fetchedMovies.isEmpty ? 0 : 1)
            pagination.finishFetching(page: page, totalPages: derivedTotalPages)
        } catch {
            guard !Task.isCancelled else { return }
            listErrorMessage = error.localizedDescription
            if !isFirstPage {
                pagination.cancelFetching()
            }
        }
    }

    private func resetAllMoviesState() {
        allMovies = []
        loadedMovieIDs = []
        pagination.reset()
        listErrorMessage = nil
    }

    private struct HighlightsSnapshot {
        let popular: [Movie]
        let topRated: [Movie]
        let newReleases: [Movie]
    }

    private func fetchHighlightsSnapshot() async throws -> HighlightsSnapshot {
        async let popular = repository.discoverMovies(filters: popularFilter.queryItems)
        async let topRated = repository.discoverMovies(filters: topRatedFilter.queryItems)
        async let newReleases = repository.discoverMovies(filters: newReleaseFilter.queryItems)

        return try await HighlightsSnapshot(
            popular: popular,
            topRated: topRated,
            newReleases: newReleases
        )
    }

    private var popularFilter: DiscoverFilter {
        DiscoverFilter(
            sortOption: .popularityDesc,
            withGenres: [genreId],
            primaryReleaseDateLTE: dateString(from: Date()),
            includeAdult: false
        )
    }

    private var topRatedFilter: DiscoverFilter {
        DiscoverFilter(
            sortOption: .voteAverageDesc,
            withGenres: [genreId],
            primaryReleaseDateLTE: dateString(from: Date()),
            minVoteAverage: 7.0,
            minVoteCount: 200,
            includeAdult: false
        )
    }

    private var newReleaseFilter: DiscoverFilter {
        DiscoverFilter(
            sortOption: .releaseDateDesc,
            withGenres: [genreId],
            primaryReleaseDateGTE: dateString(daysOffset: -120),
            primaryReleaseDateLTE: dateString(from: Date()),
            minVoteAverage: 5.0,
            includeAdult: false
        )
    }

    private func allMoviesFilter(page: Int) -> DiscoverFilter {
        switch selectedSort {
        case .popular:
            return DiscoverFilter(
                sortOption: selectedSort.sortOption,
                withGenres: [genreId],
                primaryReleaseDateLTE: dateString(from: Date()),
                includeAdult: false,
                page: page
            )
        case .topRated:
            return DiscoverFilter(
                sortOption: selectedSort.sortOption,
                withGenres: [genreId],
                primaryReleaseDateLTE: dateString(from: Date()),
                minVoteAverage: 6.0,
                minVoteCount: 200,
                includeAdult: false,
                page: page
            )
        case .newest:
            return DiscoverFilter(
                sortOption: selectedSort.sortOption,
                withGenres: [genreId],
                primaryReleaseDateLTE: dateString(from: Date()),
                includeAdult: false,
                page: page
            )
        }
    }

    private func dateString(daysOffset: Int, from referenceDate: Date = Date()) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysOffset, to: referenceDate) ?? referenceDate
        return dateString(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}
