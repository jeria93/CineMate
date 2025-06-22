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

    func fetchPersonMovieCredits(for personId: Int) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .personMovieCredits(personId))
        return result.results
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        return try await request(endpoint: .movieDetail(movieId))
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        return try await request(endpoint: .personDetail(personId))
    }

    func fetchPopularMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .popular)
        return result.results
    }

    func fetchTopRatedMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .topRated)
        return result.results
    }

    func fetchTrendingMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .trending)
        return result.results
    }

    func fetchUpcomingMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: .upcoming)
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
            throw TMDBError.decodingFailed
        }
    }

}

// ide: skapa en extension om denna fil blir för lång, varje extension kan ha respektive endpoints, tex söka, hämta etc
