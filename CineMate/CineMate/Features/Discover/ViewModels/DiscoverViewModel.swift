//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation
import SwiftUI

/// ViewModel responsible for managing the Discover screen state.
///
/// - Fetches and caches multiple movie sections (Top Rated, Popular, Now Playing, Trending, Upcoming, Horror).
/// - Applies local filtering to ensure Upcoming movies are relevant (future releases only).
/// - Supports dynamic genre filtering with in-memory caching to avoid redundant network calls.
/// - Cancels in-flight requests when switching genres rapidly.
@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var error: SearchError?
    @Published var filters = DiscoverFilter()

    @Published var topRatedMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var trendingMovies: [Movie] = []
    @Published var upcomingMovies: [Movie] = []
    @Published var horrorMovies: [Movie] = []

    @Published var genres: [Genre] = ProcessInfo.processInfo.isPreview ? GenrePreviewData.genres : []

    /// Returns `true` if all movie sections are empty.
    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty &&
        upcomingMovies.isEmpty &&
        horrorMovies.isEmpty
    }

    /// Currently selected genre ID. `nil` means "All genres".
    /// Setting this triggers `filterSections()`.
    @Published var selectedGenreId: Int? = nil {
        didSet {
            Task { await filterSections() }
        }
    }

    // MARK: - Private State

    /// Task for fetching all sections to prevent duplicate API calls.
    private var fetchAllTask: Task<Void, Never>?

    /// Task for filtering sections with in-flight cancel support.
    private var filterSectionsTask: Task<Void, Never>?
    
    /// Cached sections, keyed by genre ID (`nil` = all genres).
    private var sectionCache: [Int?: MovieSections] = [:]

    /// Repository responsible for TMDB movie fetches.
    private let repository: MovieProtocol

    // MARK: - Initialization

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
        Task { await fetchGenres() }
    }

    // MARK: - Public API

    /// Filters all Discover sections for the selected genre.
    ///
    /// - Cancels any in-flight filter task before starting a new one.
    /// - Maintains the same section order as `fetchAllSections()`.
    /// - Filters Upcoming movies to future dates and Trending to the last 5 years.
    func filterSections() async {
        // 1. Cancel any running task
        filterSectionsTask?.cancel()

        // 2. Start a new detached task (avoids blocking UI)
        filterSectionsTask = Task.detached(priority: .medium) { [weak self] in
            guard let self else { return }

            let key = await self.selectedGenreId

            // Serve cached result if available
            if let cached = await self.sectionCache[key] {
                await MainActor.run { self.apply(cached) }
                return
            }

            // Handle "All" selection
            if key == nil {
                if let allCached = await self.sectionCache[nil] {
                    await MainActor.run { self.apply(allCached) }
                } else {
                    await self.fetchAllSections()
                }
                return
            }

            guard let genreId = key else { return }

            // Prepare queries
            let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!

            do {
                async let topRated = self.repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .voteAverageDesc, withGenres: [genreId]).queryItems
                )
                async let popular = self.repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .popularityDesc, withGenres: [genreId]).queryItems
                )
                async let nowPlaying = self.repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .releaseDateDesc, withGenres: [genreId]).queryItems
                )
                async let trendingRaw = self.repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .popularityDesc, withGenres: [genreId], minVoteAverage: 5.0).queryItems
                )
                async let upcomingRaw = self.repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .releaseDateAsc, withGenres: [genreId]).queryItems
                    + [URLQueryItem(name: "primary_release_date.gte", value: DateHelper.todayString())]
                )

                // Local filtering for relevance
                let upcomingFiltered = try await upcomingRaw.filter {
                    guard let date = $0.releaseDate.flatMap(DateHelper.parse) else { return false }
                    return date >= Date()
                }

                let trendingFiltered = try await trendingRaw.filter {
                    guard let date = $0.releaseDate.flatMap(DateHelper.parse) else { return false }
                    return date >= fiveYearsAgo
                }

                // Build section state
                let sections = MovieSections(
                    topRated:   try await topRated,
                    popular:    try await popular,
                    nowPlaying: try await nowPlaying,
                    trending:   trendingFiltered,
                    upcoming:   upcomingFiltered,
                    horror:     []
                )

                // Cache and apply if not cancelled
                if !Task.isCancelled {
                    await MainActor.run {
                        self.sectionCache[key] = sections
                        self.apply(sections)
                        self.isLoading = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.error = .custom(error.localizedDescription)
                        self.isLoading = false
                    }
                }
            }
        }

        await filterSectionsTask?.value
    }

    /// Fetches all sections for the "All genres" state.
    ///
    /// - Uses caching to avoid duplicate requests.
    /// - Filters Upcoming movies to future dates and Trending to the last 5 years.
    func fetchAllSections() async {
        if let cached = sectionCache[nil] {
            apply(cached)
            return
        }
        if let task = fetchAllTask {
            await task.value
            return
        }

        fetchAllTask = Task {
            defer { fetchAllTask = nil }

            guard !ProcessInfo.processInfo.isPreview else { return }
            guard !SecretManager.bearerToken.isEmpty else {
                self.error = .custom("Missing API token.")
                return
            }

            isLoading = true
            error = nil

            do {
                async let topRated   = repository.fetchTopRatedMovies()
                async let popular    = repository.fetchPopularMovies()
                async let nowPlaying = repository.fetchNowPlayingMovies()
                async let trendingRaw   = repository.fetchTrendingMovies()

                async let upcomingRaw = repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .releaseDateAsc).queryItems
                    + [URLQueryItem(name: "primary_release_date.gte", value: DateHelper.todayString())]
                )

                async let horror = repository.discoverMovies(
                    filters: DiscoverFilter(withGenres: [27]).queryItems
                )

                let upcomingFiltered = try await upcomingRaw.filter {
                    guard let date = $0.releaseDate.flatMap(DateHelper.parse) else { return false }
                    return date >= Date()
                }

                let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
                let trendingFiltered = try await trendingRaw.filter {
                    guard let date = $0.releaseDate.flatMap(DateHelper.parse) else { return false }
                    return date >= fiveYearsAgo
                }

                let sections = MovieSections(
                    topRated:   try await topRated,
                    popular:    try await popular,
                    nowPlaying: try await nowPlaying,
                    trending:   trendingFiltered,
                    upcoming:   upcomingFiltered,
                    horror:     try await horror
                )

                sectionCache[nil] = sections
                apply(sections)
            } catch {
                self.error = .custom(error.localizedDescription)
            }

            isLoading = false
        }

        await fetchAllTask?.value
    }

    // MARK: - Private Helpers

    /// Fetches all available genres from the repository.
    private func fetchGenres() async {
        do {
            genres = try await repository.fetchGenres()
        } catch {
            print("DiscoverViewModel: Failed to load genres:", error)
        }
    }

    /// Applies a `MovieSections` container to all published arrays.
    private func apply(_ s: MovieSections) {
        topRatedMovies   = s.topRated
        popularMovies    = s.popular
        nowPlayingMovies = s.nowPlaying
        trendingMovies   = s.trending
        upcomingMovies   = s.upcoming
        horrorMovies     = s.horror
    }
}

/// A container for all discover movie sections.
/// The order matches how sections are displayed in the UI.
private struct MovieSections {
    let topRated:   [Movie]
    let popular:    [Movie]
    let nowPlaying: [Movie]
    let trending:   [Movie]
    let upcoming:   [Movie]
    let horror:     [Movie]
}
