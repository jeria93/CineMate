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
    }
    
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
}
