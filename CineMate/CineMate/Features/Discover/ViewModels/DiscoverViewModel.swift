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
/// - Publishes separate arrays for each section to drive the UI directly.
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

    /// Currently selected genre ID. Setting this triggers `filterSections()`.
    @Published var selectedGenreId: Int? = nil {
        didSet {
            Task { await filterSections() }
        }
    }

    /// Returns `true` if all discover sections are empty.
    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty &&
        upcomingMovies.isEmpty &&
        horrorMovies.isEmpty
    }

    // MARK: - Private State

    /// Handles the currently running fetch task to prevent duplicate API calls.
    private var fetchAllTask: Task<Void, Never>?

    /// In-memory cache of fetched sections, keyed by optional genre ID.
    /// - `nil` = unfiltered (all genres)
    /// - `Int` = specific genre ID
    private var sectionCache: [Int?: MovieSections] = [:]

    /// The repository responsible for fetching movies from TMDB.
    private let repository: MovieProtocol

    // MARK: - Initialization

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
        Task { await fetchGenres() }
    }

    // MARK: - Public API

    /// Fetches all Discover sections once per session.
    ///
    /// - Caches results in `sectionCache` under the `nil` key (unfiltered).
    /// - Ensures Upcoming movies are relevant:
    ///   - Adds `primary_release_date.gte` with today's date to the API query.
    ///   - Applies **local filtering** to remove any past releases that TMDB may return.
    /// - Updates all published section arrays upon completion.
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
                async let trending   = repository.fetchTrendingMovies()

                // Fetch Upcoming movies with releaseDate >= today
                async let upcomingRaw = repository.discoverMovies(
                    filters: DiscoverFilter(sortOption: .releaseDateAsc).queryItems
                        + [URLQueryItem(name: "primary_release_date.gte", value: DateHelper.todayString())]
                )

                // Fetch Horror movies separately (static genre ID 27)
                async let horror = repository.discoverMovies(
                    filters: DiscoverFilter(withGenres: [27]).queryItems
                )

                // Local filter to remove any movies released before today
                let upcomingFiltered = try await upcomingRaw.filter {
                    guard let releaseDateString = $0.releaseDate,
                          let releaseDate = DateHelper.parse(releaseDateString) else { return false }
                    return releaseDate >= Date()
                }

                let sections = MovieSections(
                    topRated:   try await topRated,
                    popular:    try await popular,
                    nowPlaying: try await nowPlaying,
                    trending:   try await trending,
                    upcoming:   upcomingFiltered,
                    horror:     try await horror
                )

                // Cache & apply
                sectionCache[nil] = sections
                apply(sections)
            } catch {
                self.error = .custom(error.localizedDescription)
            }

            isLoading = false
        }

        await fetchAllTask?.value
    }

    /// Filters all Discover sections for the selected genre.
    ///
    /// - Maintains the same section order as `fetchAllSections()`.
    /// - Uses in-memory caching to avoid redundant API calls.
    /// - Filters Upcoming movies using both API (`release_date.gte`) and local verification.
    func filterSections() async {
        let key = selectedGenreId

        // 1. Return cached result if available
        if let cached = sectionCache[key] {
            apply(cached)
            return
        }

        // 2. If no genre selected → fallback to full fetch
        guard let genreId = key else {
            await fetchAllSections()
            return
        }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            async let topRated = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .voteAverageDesc, withGenres: [genreId]).queryItems
            )
            async let popular = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .popularityDesc, withGenres: [genreId]).queryItems
            )
            async let nowPlaying = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .releaseDateDesc, withGenres: [genreId]).queryItems
            )
            async let trending = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .popularityDesc, withGenres: [genreId]).queryItems
                + [URLQueryItem(name: "time_window", value: "week")]
            )

            // Upcoming movies for the selected genre
            async let upcomingRaw = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .releaseDateAsc, withGenres: [genreId]).queryItems
                    + [URLQueryItem(name: "primary_release_date.gte", value: DateHelper.todayString())]
            )

            // Local filtering to ensure Upcoming movies are future releases
            let upcomingFiltered = try await upcomingRaw.filter {
                guard let releaseDateString = $0.releaseDate,
                      let releaseDate = DateHelper.parse(releaseDateString) else { return false }
                return releaseDate >= Date()
            }

            let sections = MovieSections(
                topRated:   try await topRated,
                popular:    try await popular,
                nowPlaying: try await nowPlaying,
                trending:   try await trending,
                upcoming:   upcomingFiltered,
                horror:     []
            )

            sectionCache[key] = sections
            apply(sections)
        } catch {
            self.error = .custom(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    /// Loads the list of genres from the repository (called once on init).
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

/// A container struct that groups all Discover sections in a single state.
/// The order matches how sections are displayed in the UI.
private struct MovieSections {
    let topRated:   [Movie]
    let popular:    [Movie]
    let nowPlaying: [Movie]
    let trending:   [Movie]
    let upcoming:   [Movie]
    let horror:     [Movie]
}
