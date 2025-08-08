//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation
import SwiftUI

/// **DiscoverViewModel**
///
/// Manages the Discover screen state, including multiple movie sections and genre-based filtering.
///
/// ### Responsibilities
/// - Fetch and cache multiple movie sections (Top Rated, Popular, Now Playing, Trending, Upcoming, Horror)
/// - Support genre-based filtering with in-memory caching to prevent redundant API calls
/// - Filter Upcoming movies to future releases and Trending movies to the last 5 years
/// - Manage in-flight protection for simultaneous section fetches and filtering
/// - Handle errors and loading states for smooth UI updates
///
/// ### Usage
/// ```swift
/// @StateObject private var discoverVM = DiscoverViewModel()
///
/// // Load all sections (initial)
/// Task { await discoverVM.fetchAllSections() }
///
/// // Change genre (auto-triggers filterSections)
/// discoverVM.selectedGenreId = 28 // e.g., Action
/// ```
@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published State (UI bindings)

    /// Current combined results for the selected genre (if used)
    @Published var results: [Movie] = []

    /// Indicates whether any section is currently loading
    @Published var isLoading = false

    /// Holds any error that occurred during fetching or filtering
    @Published var error: SearchError?

    /// Current Discover filter (sorting, genre, etc.)
    @Published var filters = DiscoverFilter()

    /// Section-specific movie arrays
    @Published var topRatedMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var trendingMovies: [Movie] = []
    @Published var upcomingMovies: [Movie] = []
    @Published var horrorMovies: [Movie] = []

    /// List of genres used for filtering (mocked in previews)
    @Published var genres: [Genre] = ProcessInfo.processInfo.isPreview ? GenrePreviewData.genres : []

    /// Returns `true` if all sections are empty (used for empty-state UI)
    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty &&
        upcomingMovies.isEmpty &&
        horrorMovies.isEmpty
    }

    /// Currently selected genre ID. `nil` = All genres.
    /// Setting this triggers an async `filterSections()` call.
    @Published var selectedGenreId: Int? = nil {
        didSet {
            Task { await filterSections() }
        }
    }

    // MARK: - Private State (in-flight protection & cache)

    /// Task that fetches all sections (cancelled if a new fetch starts)
    private var fetchAllTask: Task<Void, Never>?

    /// Task that filters sections (cancelled if the user switches genres)
    private var filterSectionsTask: Task<Void, Never>?

    /// In-memory cache of sections by genre ID (`nil` = all genres)
    private var sectionCache: [Int?: MovieSections] = [:]

    /// Repository for fetching movie data (injected for production or mock)
    private let repository: MovieProtocol

    // MARK: - Initialization

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
        Task { await fetchGenres() }
    }

    // MARK: - Public API

    /// Filters all Discover sections based on the selected genre.
    /// - Cancels any in-flight filter task before starting a new one.
    /// - Uses cached results when available for faster UI response.
    func filterSections() async {
        filterSectionsTask?.cancel()
        filterSectionsTask = Task.detached(priority: .medium) { [weak self] in
            guard let self else { return }

            let key = await self.selectedGenreId

            // 1. Use cache if available
            if let cached = await self.sectionCache[key] {
                await MainActor.run { self.apply(cached) }
                return
            }

            // 2. Handle "All genres" fallback
            if key == nil {
                if let allCached = await self.sectionCache[nil] {
                    await MainActor.run { self.apply(allCached) }
                } else {
                    await self.fetchAllSections()
                }
                return
            }

            guard let genreId = key else { return }

            let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!

            do {
                // Fetch all sections in parallel
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

                // Combine into section container
                let sections = MovieSections(
                    topRated:   try await topRated,
                    popular:    try await popular,
                    nowPlaying: try await nowPlaying,
                    trending:   trendingFiltered,
                    upcoming:   upcomingFiltered,
                    horror:     []
                )

                // Cache & apply if not cancelled
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

    /// Fetches all sections for "All genres" and caches the result.
    /// - Uses in-flight protection to prevent overlapping calls.
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
                // Fetch multiple sections concurrently
                async let topRated    = repository.fetchMovies(category: .topRated, page: 1).results
                async let popular     = repository.fetchMovies(category: .popular, page: 1).results
                async let nowPlaying  = repository.fetchNowPlayingMovies()
                async let trendingRaw = repository.fetchMovies(category: .trending, page: 1).results

                async let upcomingRaw = repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .releaseDateAsc).queryItems
                    + [URLQueryItem(name: "primary_release_date.gte", value: DateHelper.todayString())]
                )

                async let horror = repository.discoverMovies(
                    filters: DiscoverFilter(withGenres: [27]).queryItems
                )

                // Local filtering
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

                // Cache and apply
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

    /// Fetches the list of available genres from the repository.
    private func fetchGenres() async {
        do {
            genres = try await repository.fetchGenres()
        } catch {
            print("DiscoverViewModel: Failed to load genres:", error)
        }
    }

    /// Applies a `MovieSections` container to all published properties.
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
private struct MovieSections {
    let topRated:   [Movie]
    let popular:    [Movie]
    let nowPlaying: [Movie]
    let trending:   [Movie]
    let upcoming:   [Movie]
    let horror:     [Movie]
}
