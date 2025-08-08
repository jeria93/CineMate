//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation
import SwiftUI

/// **MovieViewModel**
///
/// Manages the movie list, pagination, and detailed movie data for the CineMate app.
///
/// ### Responsibilities
/// - Fetch and cache paginated movie lists from the repository
/// - Load movie details including credits, videos, recommendations, and watch providers
/// - Manage favorites in-memory
/// - Provide in-flight protection to prevent duplicate or conflicting network requests
/// - Handle errors and loading states for smooth UI updates
///
/// ### Usage
/// ```swift
/// @StateObject private var movieVM = MovieViewModel()
///
/// // Load first page
/// Task { await movieVM.loadMovies() }
///
/// // Load next page when user scrolls to bottom
/// Task { await movieVM.loadNextPageIfNeeded(currentItem: lastMovie) }
///
/// // Load detailed info for a selected movie
/// Task { await movieVM.loadMovieDetails(for: movie.id) }
/// ```
@MainActor
final class MovieViewModel: ObservableObject {

    // MARK: - Published State (UI bindings)

    /// Current list of movies for the selected category (paginated)
    @Published var movies: [Movie] = []

    /// Loaded movie detail for the currently viewed movie
    @Published var movieDetail: MovieDetail?

    /// Loaded credits for the current movie
    @Published var movieCredits: MovieCredits?

    /// Recommended movies based on the current movie
    @Published var recommendedMovies: [Movie]?

    /// Region-specific watch providers for the current movie
    @Published var watchProviderRegion: WatchProviderRegion?

    /// Trailer and video content for the current movie
    @Published var movieVideos: [MovieVideo]?

    /// Indicates if a movie detail request is currently in progress
    @Published var isLoadingDetail = false

    /// Currently selected movie category (Popular, Top Rated, etc.)
    @Published var selectedCategory: MovieCategory = .popular

    /// Indicates if the list (first page or refresh) is currently loading
    @Published var isLoading = false

    /// Optional error message to display in the UI
    @Published var errorMessage: String?

    /// Set of favorite movie IDs stored locally (in-memory)
    @Published var favoriteMovies: Set<Int> = []

    // MARK: - Pagination
    /// Manages page tracking and prevents duplicate next-page fetches
    let pagination = PaginationManager()

    // MARK: - Dependencies
    private let repository: MovieProtocol
    /// Exposes the underlying repository (useful for previews/tests)
    var underlyingRepository: MovieProtocol { repository }

    // MARK: - In-flight guards
    /// Tracks which movie IDs are currently fetching details to avoid duplicates
    private var detailInFlight: Set<Int> = []

    /// Current list-fetch task, used for cancellation and race-condition protection
    private var listTask: Task<Void, Never>?

    // MARK: - Initialization
    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - List Loading

    /// Loads movies for the current category, supporting pagination.
    /// Cancels any in-flight list-fetch to prevent race conditions.
    /// - Parameter page: The page to load (1 for first page/reset).
    func loadMovies(page: Int = 1) async {
        // Cancel any previous list task to prevent overlapping requests
        listTask?.cancel()

        listTask = Task {
            if page == 1 {
                pagination.reset()
                isLoading = true
                errorMessage = nil
            } else {
                guard pagination.startFetchingNextPage() else { return }
            }

            defer { isLoading = false }

            do {
                let response = try await repository.fetchMovies(category: selectedCategory, page: page)
                guard !Task.isCancelled else { return } // Skip if cancelled mid-fetch

                // Update movies array
                if page == 1 {
                    movies = response.results
                } else {
                    movies.append(contentsOf: response.results)
                }

                pagination.finishFetching(page: response.page, totalPages: response.totalPages)
                errorMessage = nil
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription

                    // Ensure pagination state is consistent after an error
                    if page != 1 {
                        pagination.finishFetching(
                            page: pagination.state.currentPage,
                            totalPages: pagination.state.totalPages
                        )
                    }
                }
            }
        }

        await listTask?.value
    }

    /// Loads the next page if the given `currentItem` is the last in the list.
    /// Used for infinite scrolling.
    func loadNextPageIfNeeded(currentItem: Movie) async {
        guard let last = movies.last,
              last.id == currentItem.id,
              pagination.hasMorePages else { return }

        await loadMovies(page: pagination.state.currentPage + 1)
    }

    // MARK: - Detail Loading

    /// Loads full detail, credits, recommendations, watch providers, and videos for a given movie.
    /// - Parameter movieId: The ID of the movie to load details for.
    func loadMovieDetails(for movieId: Int) async {
        guard !detailInFlight.contains(movieId) else { return }
        detailInFlight.insert(movieId)

        isLoadingDetail = true
        defer {
            isLoadingDetail = false
            detailInFlight.remove(movieId)
        }

        // Fetch all detail endpoints concurrently
        async let details     = repository.fetchMovieDetails(for: movieId)
        async let credits     = repository.fetchMovieCredits(for: movieId)
        async let recommended = repository.fetchRecommendedMovies(for: movieId)
        async let providers   = repository.fetchWatchProviders(for: movieId)
        async let videos      = repository.fetchMovieVideos(for: movieId)

        do {
            let d = try await details
            movieDetail = d

            // Cache a lightweight stub for immediate UI usage
            if !movies.contains(where: { $0.id == d.id }) {
                movies.append(makeStub(from: d))
            }

            movieCredits        = try await credits
            recommendedMovies   = try await recommended
            watchProviderRegion = try await providers
            movieVideos         = try await videos
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Favorites

    /// Adds or removes a movie from the in-memory favorites set.
    func toggleFavorite(for movie: Movie) {
        if favoriteMovies.contains(movie.id) {
            favoriteMovies.remove(movie.id)
        } else {
            favoriteMovies.insert(movie.id)
        }
    }

    /// Returns `true` if the given movie is currently marked as favorite.
    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains(movie.id)
    }

    // MARK: - Helpers

    /// Returns the best available `Movie` for a given ID, preferring list, then detail, then recommendations.
    func movie(by id: Int) -> Movie? {
        if let existing = movies.first(where: { $0.id == id }) {
            return existing
        }
        if let detail = movieDetail, detail.id == id {
            return makeStub(from: detail)
        }
        if let rec = recommendedMovies?.first(where: { $0.id == id }) {
            return rec
        }
        return nil
    }

    /// Caches a stub `Movie` for immediate UI usage (prevents empty placeholders in navigation).
    func cacheStub(_ stub: Movie) {
        guard !movies.contains(where: { $0.id == stub.id }) else { return }
        movies.append(stub)
    }

    /// Converts a full `MovieDetail` into a lightweight `Movie` for use in lists.
    private func makeStub(from detail: MovieDetail) -> Movie {
        Movie(
            id: detail.id,
            title: detail.title,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            releaseDate: detail.releaseDate,
            voteAverage: detail.voteAverage,
            genres: detail.genreNames
        )
    }
}
