//
//  TMDBService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Handles all TMDB API requests for movies, people, search and discovery.
/// Used by `MovieRepository` as the network layer.
final class TMDBService {

    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession.shared

    private var userRegion: String {
        Locale.current.region?.identifier ?? "US"
    }

    // MARK: - Movie Lists with Paging
    func fetchPopularMovies(page: Int = 1, region: String? = nil) async throws -> MovieResult {
        try await pagedRequest(endpoint: .popular, page: page, region: region)
    }

    func fetchTopRatedMovies(page: Int = 1, region: String? = nil) async throws -> MovieResult {
        try await pagedRequest(endpoint: .topRated, page: page, region: region)
    }

    func fetchTrendingMovies(page: Int = 1, region: String? = nil) async throws -> MovieResult {
        try await pagedRequest(endpoint: .trending, page: page, region: region)
    }

    func fetchUpcomingMovies(page: Int = 1, region: String? = nil) async throws -> MovieResult {
        try await pagedRequest(endpoint: .upcoming, page: page, region: region)
    }

    // MARK: - Helper for paged endpoints
    private func pagedRequest(endpoint: TMDBEndpoint, page: Int, region: String?) async throws -> MovieResult {
        var query = regionQueryItems(region)
        query.append(URLQueryItem(name: "page", value: "\(page)"))
        return try await request(endpoint: endpoint, queryItems: query)
    }

    // MARK: - Movie Details
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        try await request(endpoint: .movieDetail(movieId))
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        try await request(endpoint: .credits(movieId))
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        let result: MovieVideoResult = try await request(endpoint: .videos(movieId))
        return result.results
    }

    func fetchRecommendedMovies(for movieId: Int, page: Int = 1) async throws -> MovieResult {
        let query = [URLQueryItem(name: "page", value: "\(page)")]
        return try await request(endpoint: .recommendations(movieId), queryItems: query)
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProvidersResponse {
        try await request(endpoint: .watchProviders(movieId))
    }

    func fetchWatchProviderRegion(for movieId: Int) async throws -> WatchProviderRegion {
        let response: WatchProvidersResponse = try await request(endpoint: .watchProviders(movieId))
        let regionCode = Locale.current.region?.identifier ?? "US"
        return response.results[regionCode] ?? .empty
    }

    // MARK: - Person
    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        try await request(endpoint: .personDetail(personId))
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        let response: PersonMovieCreditsResponse = try await request(endpoint: .personMovieCredits(personId))
        return response.cast
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        try await request(endpoint: .personExternalIDs(personId))
    }

    // MARK: - Search & Discover
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResult {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        return try await request(endpoint: .search(query), queryItems: queryItems)
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .discover, queryItems: filters)
        return result.results
    }

    // MARK: - Misc
    func fetchNowPlayingMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .nowPlaying)
        return result.results
    }

    func fetchGenres() async throws -> [Genre] {
        let response: GenreResponse = try await request(endpoint: .movieGenres)
        return response.genres
    }

    // MARK: - Helpers
    private func regionQueryItems(_ region: String?) -> [URLQueryItem] {
        let resolvedRegion = region ?? userRegion
#if DEBUG
        print("Using region: \(resolvedRegion)")
#endif
        return [URLQueryItem(name: "region", value: resolvedRegion)]
    }

    // MARK: - Generic Request
    func request<Model: Decodable>(endpoint: TMDBEndpoint, queryItems: [URLQueryItem] = []) async throws -> Model {
        guard var components = URLComponents(string: "\(baseURL)\(endpoint.path)") else {
            throw TMDBError.badURL
        }
        if !queryItems.isEmpty { components.queryItems = queryItems }

        guard let url = components.url else { throw TMDBError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]

        let (data, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Model.self, from: data)
    }
}
