//
//  DiscoverViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
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

    var allSectionsAreEmpty: Bool {
        topRatedMovies.isEmpty &&
        popularMovies.isEmpty &&
        nowPlayingMovies.isEmpty &&
        trendingMovies.isEmpty
    }

    private let repository: MovieProtocol

    init(repository: MovieProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchDiscoverMovies() async {
        guard !ProcessInfo.processInfo.isPreview else {
            print("Skipping discoverMovies fetch in preview mode.")
            return
        }

        isLoading = true
        error = nil
        do {
            results = try await repository.discoverMovies(filters: filters.queryItems)
        } catch {
            self.error = .networkFailure
            results = []
        }
        isLoading = false
    }

    func fetchAllSections() async {
        guard !ProcessInfo.processInfo.isPreview else {
            print("Skipping section fetches in preview mode.")
            return
        }

        async let topRated = repository.fetchTopRatedMovies()
        async let popular = repository.fetchPopularMovies()
        async let nowPlaying = repository.fetchNowPlayingMovies()
        async let trending = repository.fetchTrendingMovies()

        do {
            topRatedMovies = try await topRated
            popularMovies = try await popular
            nowPlayingMovies = try await nowPlaying
            trendingMovies = try await trending
        } catch {
            print("Failed to load one or more sections: \(error)")
        }
    }
}
