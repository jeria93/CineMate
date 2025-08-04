//
//  MovieViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation
import SwiftUI

/// Responsible for loading and caching movie lists, detail data, credits,
/// recommendations, and related metadata. Uses in-flight guards to avoid
/// duplicate concurrent network requests and provides lightweight stubs so
/// the UI can show something immediately while full detail loads.
@MainActor
final class MovieViewModel: ObservableObject {
    // MARK: - State
    @Published var movies: [Movie] = []
    @Published var movieDetail: MovieDetail?
    @Published var movieCredits: MovieCredits?
    @Published var recommendedMovies: [Movie]?
    @Published var watchProviderRegion: WatchProviderRegion?
    @Published var movieVideos: [MovieVideo]?
    @Published var isLoadingDetail = false

    @Published var selectedCategory: MovieCategory = .popular
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var favoriteMovies: Set<Int> = []

    // Dependencies
    private let repository: MovieProtocol
    var underlyingRepository: MovieProtocol { repository }

    // Caches / in-flight guards
    private var listCache: [MovieCategory: [Movie]] = [:]
    private var listInFlight: Task<Void, Never>? = nil
    private var detailInFlight: Set<Int> = []

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    // MARK: - Favorites
    func toggleFavorite(for movie: Movie) {
        if favoriteMovies.contains(movie.id) {
            favoriteMovies.remove(movie.id)
        } else {
            favoriteMovies.insert(movie.id)
        }
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favoriteMovies.contains(movie.id)
    }

    // MARK: - List Loading

    /// Loads the movie list for the currently selected category.
    /// Uses cache and in-flight guard to prevent duplicate work.
    func loadMovies() async {
        if let cached = listCache[selectedCategory] {
            movies = cached
            return
        }

        if let task = listInFlight {
            await task.value
            return
        }

        listInFlight = Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let fetched: [Movie]
                switch selectedCategory {
                case .popular: fetched = try await repository.fetchPopularMovies()
                case .topRated: fetched = try await repository.fetchTopRatedMovies()
                case .trending: fetched = try await repository.fetchTrendingMovies()
                case .upcoming: fetched = try await repository.fetchUpcomingMovies()
                }

                movies = fetched
                listCache[selectedCategory] = fetched
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        await listInFlight?.value
        listInFlight = nil
    }

    // MARK: - Detail Loading

    /// Loads detailed data (detail, credits, recommendations, providers, videos)
    /// for a specific movie ID. Guards against duplicate concurrent loads.
    func loadMovieDetails(for movieId: Int) async {
        guard !detailInFlight.contains(movieId) else { return }
        detailInFlight.insert(movieId)

        isLoadingDetail = true
        defer {
            isLoadingDetail = false
            detailInFlight.remove(movieId)
        }

        async let details     = repository.fetchMovieDetails(for: movieId)
        async let credits     = repository.fetchMovieCredits(for: movieId)
        async let recommended = repository.fetchRecommendedMovies(for: movieId)
        async let providers   = repository.fetchWatchProviders(for: movieId)
        async let videos      = repository.fetchMovieVideos(for: movieId)

        do {
            let d = try await details
            movieDetail = d

            // Cache a lightweight stub so UI that asks via `movie(by:)` has immediate data.
            if !movies.contains(where: { $0.id == d.id }) {
                let stub = makeStub(from: d)
                movies.append(stub)
            }

            movieCredits        = try await credits
            recommendedMovies   = try await recommended
            watchProviderRegion = try await providers
            movieVideos         = try await videos
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("MovieViewModel loadMovieDetails error:", error)
        }
    }


    // MARK: - Helpers

    /// Returns a movie by ID, preferring:
    /// 1. Explicitly cached list item.
    /// 2. Transient stub derived from detail.
    /// 3. Recommendation fallback.
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

    /// Inject a stub externally (e.g., before navigation) so detail view has something instantly.
    func cacheStub(_ stub: Movie) {
        guard !movies.contains(where: { $0.id == stub.id }) else { return }
        movies.append(stub)
    }

    /// Builds a minimal `Movie` from full `MovieDetail`.
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
