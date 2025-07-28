//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation
import SwiftUI


/// ViewModel responsible for driving the Discover screen.
///
/// - Maintains published properties for each movie section,
///   loading state, errors, and genre selection.
/// - Fetches data from a `MovieProtocol` repository, with in-memory caching
///   and “in-flight” guarding to prevent duplicate network calls.
/// - Supports filtering by genre and preserves results across app sessions.
@MainActor
final class DiscoverViewModel: ObservableObject {
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
    @Published var selectedGenreId: Int? = nil {
        didSet {
            Task {
                await filterSections()
            }
        }
    }

    /// Returns `true` if all sections are empty.
    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty &&
        upcomingMovies.isEmpty &&
        horrorMovies.isEmpty
    }

    // MARK: - Private state for caching & guarding

    /// Task handle to prevent duplicate “fetchAllSections” calls.
    private var fetchAllTask: Task<Void, Never>?
    /// Simple in-memory cache keyed by optional genre ID.
    private var sectionCache: [Int?: MovieSections] = [:]

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
        Task { await fetchGenres() }
    }

    // MARK: - Public API

    /// Fetches all Discover sections (Top Rated, Popular, Now Playing, Trending,
    /// Upcoming, Horror) exactly once per app session.
    ///
    /// Uses the in-memory cache if available, and guards against concurrent calls.
    /// Sets `isLoading`, clears `error`, and applies results when done.
    func fetchAllSections() async {
        // Return cached if present
        if let cached = sectionCache[nil] {
            apply(cached)
            return
        }
        // 2) If already in-flight, await it
        if let task = fetchAllTask {
            await task.value
            return
        }
        // 3) Kick off new fetch task
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
                async let upcoming   = repository.fetchUpcomingMovies()
                async let horror     = repository.discoverMovies(
                    filters: DiscoverFilter(withGenres: [27]).queryItems
                )

                let sections = MovieSections(
                    topRated:   try await topRated,
                    popular:    try await popular,
                    nowPlaying: try await nowPlaying,
                    trending:   try await trending,
                    upcoming:   try await upcoming,
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

        // Await completion
        await fetchAllTask?.value
    }

    /// Filters the Discover sections by the selected genre.
    ///
    /// Falls back to `fetchAllSections()` if no genre is selected.
    /// Uses the same cache + in-flight guard logic.
    func filterSections() async {
        let key = selectedGenreId

        // 1) Return cached if present
        if let cached = sectionCache[key] {
            apply(cached)
            return
        }
        // 2) No genre chosen → reload all
        guard let genreId = key else {
            await fetchAllSections()
            return
        }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            async let topRated = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .voteAverageDesc,
                                        withGenres: [genreId]).queryItems
            )
            async let popular = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .popularityDesc,
                                        withGenres: [genreId]).queryItems
            )
            async let trending = repository.discoverMovies(
                filters: DiscoverFilter(sortOption: .popularityDesc,
                                        withGenres: [genreId]).queryItems
                + [ URLQueryItem(name: "time_window", value: "week") ]
            )

            let sections = MovieSections(
                topRated: try await topRated,
                popular:  try await popular,
                nowPlaying: [],
                trending: try await trending,
                upcoming: [],
                horror:   []
            )

            // Cache & apply
            sectionCache[key] = sections
            apply(sections)
        } catch {
            self.error = .custom(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers

    /// Loads the list of genres (called once on init).
    private func fetchGenres() async {
        do {
            genres = try await repository.fetchGenres()
        } catch {
            print("DiscoverViewModel: Failed to load genres:", error)
        }
    }

    /// Applies a `MovieSections` container to the individual published arrays.
    private func apply(_ s: MovieSections) {
        topRatedMovies   = s.topRated
        popularMovies    = s.popular
        nowPlayingMovies = s.nowPlaying
        trendingMovies   = s.trending
        upcomingMovies   = s.upcoming
        horrorMovies     = s.horror
    }
}

/// Simple struct bundling all sections together.
private struct MovieSections {
    let topRated:   [Movie]
    let popular:    [Movie]
    let nowPlaying: [Movie]
    let trending:   [Movie]
    let upcoming:   [Movie]
    let horror:     [Movie]
}

