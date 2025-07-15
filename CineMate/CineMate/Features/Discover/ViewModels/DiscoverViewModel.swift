//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import Foundation

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

    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty &&
        upcomingMovies.isEmpty &&
        horrorMovies.isEmpty
    }

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
        Task { await fetchGenres() }
    }

    /// Fetches all main movie sections (Top Rated, Popular, Now Playing, Trending, Upcoming, Horror).
    ///
    /// This method is typically used when no genre filter is selected and the app should display
    /// standard, unfiltered content.
    ///
    /// The method runs six async requests in parallel to speed up the data loading.
    /// If the app is running in preview mode or if the bearer token is missing,
    /// the function exits early.
    ///
    /// The `isLoading` flag is used to indicate loading state, and any error is stored in `error`.
    func fetchAllSections() async {
        guard !ProcessInfo.processInfo.isPreview else {
            print("Skipping section fetch in preview.")
            return
        }

        guard !SecretManager.bearerToken.isEmpty else {
            print("Bearer token is missing.")
            error = .custom("Missing API token.")
            return
        }

        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            async let topRated = repository.fetchTopRatedMovies()
            async let popular = repository.fetchPopularMovies()
            async let nowPlaying = repository.fetchNowPlayingMovies()
            async let trending = repository.fetchTrendingMovies()
            async let upcoming = repository.fetchUpcomingMovies()
            async let horror = repository.discoverMovies(filters: DiscoverFilter(withGenres: [27]).queryItems)

            topRatedMovies = try await topRated
            popularMovies = try await popular
            nowPlayingMovies = try await nowPlaying
            trendingMovies = try await trending
            upcomingMovies = try await upcoming
            horrorMovies = try await horror
        } catch {
            print("Failed to load one or more sections: \(error.localizedDescription)")
            self.error = .custom(error.localizedDescription)
        }
    }

    /// Fetches available movie genres from the TMDB API.
    ///
    /// This method is called once during ViewModel initialization and
    /// populates the `genres` array used for filtering content.
    ///
    /// If the request fails, it prints the error but does not update the `error` property.
    func fetchGenres() async {
        do {
            genres = try await repository.fetchGenres()
        } catch {
            print("Failed to load genres: \(error.localizedDescription)")
        }
    }

    /// Filters movie sections based on the currently selected genre.
    ///
    /// If no genre is selected, the method falls back to `fetchAllSections()`.
    /// This function performs three parallel API requests using the selected genre ID:
    /// - Top Rated movies (sorted by vote average)
    /// - Popular movies (sorted by popularity)
    /// - Trending movies (filtered by genre and time window)
    ///
    /// Any previously loaded sections unrelated to the genre (e.g. Now Playing, Upcoming, Horror) are cleared.
    /// The `isLoading` flag manages loading state, and errors are captured in the `error` property.
    ///
    /// - Note: Must be called from a Swift concurrency context (`async`).
    func filterSections() async {

        // If no genre is selected, load all default sections (no filters)
        guard let genreId = selectedGenreId else {
            await fetchAllSections()
            return
        }

        // Show loading indicator while fetching, and always turn it off when done
        isLoading = true
        error = nil
        defer { isLoading = false }


        do {
            // Start fetching 3 filtered sections in parallel, based on selected genre
            async let topRated = repository.discoverMovies(filters: DiscoverFilter(
                sortOption: .voteAverageDesc,
                withGenres: [genreId]
            ).queryItems)

            async let popular = repository.discoverMovies(filters: DiscoverFilter(
                sortOption: .popularityDesc,
                withGenres: [genreId]
            ).queryItems)

            async let trending = repository.discoverMovies(filters: DiscoverFilter(
                sortOption: .popularityDesc,
                withGenres: [genreId]
            ).queryItems + [URLQueryItem(name: "time_window", value: "week")])

            // Wait for all three to finish and assign results
            topRatedMovies = try await topRated
            popularMovies = try await popular
            trendingMovies = try await trending

            // Clear unused sections to avoid showing old data
            nowPlayingMovies = []
            upcomingMovies = []
            horrorMovies = []
        } catch {
            // Handle any errors by updating the error state
            self.error = .custom(error.localizedDescription)
        }
    }
}
