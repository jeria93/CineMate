//
//  TMDBService.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

final class TMDBService {

    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession.shared

    private var userRegion: String {
        Locale.current.region?.identifier ?? "US"
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        let response: PersonMovieCreditsResponse = try await request(endpoint: .personMovieCredits(personId))
        return response.cast
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        return try await request(endpoint: .personExternalIDs(personId))
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        return try await request(endpoint: .movieDetail(movieId))
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        return try await request(endpoint: .personDetail(personId))
    }

    func fetchPopularMovies(region: String? = nil) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .popular, queryItems: regionQueryItems(region))
        return result.results
    }

    func fetchTopRatedMovies(region: String? = nil) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .topRated, queryItems: regionQueryItems(region))
        return result.results
    }

    func fetchTrendingMovies(region: String? = nil) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .trending, queryItems: regionQueryItems(region))
        return result.results
    }

    func fetchUpcomingMovies(region: String? = nil) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .upcoming, queryItems: regionQueryItems(region))
        return result.results
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        return try await request(endpoint: .credits(movieId))
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        let result: MovieVideoResult = try await request(endpoint: .videos(movieId))
        return result.results
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .recommendations(movieId))
        return result.results
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProvidersResponse {
        try await request(endpoint: .watchProviders(movieId))
    }

    func fetchWatchProviderRegion(for movieId: Int) async throws -> WatchProviderRegion {
        let response: WatchProvidersResponse = try await request(endpoint: .watchProviders(movieId))
        let regionCode = Locale.current.region?.identifier ?? "US"
        return response.results[regionCode] ?? .empty
    }

    private func regionQueryItems(_ region: String?) -> [URLQueryItem] {
        let resolvedRegion = region ?? userRegion
#if DEBUG
        print("Using region: \(resolvedRegion)")
#endif
        return [URLQueryItem(name: "region", value: resolvedRegion)]
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let queryItems = [URLQueryItem(name: "query", value: query)]
        let result: MovieResult = try await request(endpoint: .search(query), queryItems: queryItems)
        return result.results
    }

    /// Generic method that sends a GET request to TMDB and decodes the response into any Decodable model.
    ///
    /// - Parameters:
    ///   - path: The endpoint path to append to the base TMDB URL.
    ///   - queryItems: Optional query parameters to be appended to the request.
    /// - Returns: A decoded model of the specified type.
    /// - Throws: A `URLError` or decoding error if something goes wrong.
    func request<Model: Decodable>(endpoint: TMDBEndpoint, queryItems: [URLQueryItem] = []) async throws -> Model {

        guard var components = URLComponents(string: "\(baseURL)\(endpoint.path)") else {
            throw TMDBError.badURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw TMDBError.badURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]
        
        let (data, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.serverError(httpResponse.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(Model.self, from: data)
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            print("Raw JSON: \(String(data: data, encoding: .utf8) ?? "N/A")")
            throw TMDBError.decodingFailed
        }
    }

}
