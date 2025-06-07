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
    
    
    func fetchPopularMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(path: "/movie/popular")
        return result.results
    }
    
    func fetchTopRatedMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(path: "/movie/top_rated")
        return result.results
    }
    
    func fetchTrendingMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(path: "/trending/movie/week")
        return result.results
    }
    
    func fetchUpcomingMovies() async throws -> [Movie] {
        let result: MovieResult = try await request(path: "/movie/upcoming")
        return result.results
    }
    
    /// Generic method that sends a GET request to TMDB and decodes the response into any Decodable model.
    ///
    /// - Parameters:
    ///   - path: The endpoint path to append to the base TMDB URL.
    ///   - queryItems: Optional query parameters to be appended to the request.
    /// - Returns: A decoded model of the specified type.
    /// - Throws: A `URLError` or decoding error if something goes wrong.
    func request<Model: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> Model {
        var components = URLComponents(string: "\(baseURL)\(path)")!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else { throw URLError(.badURL) }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(SecretManager.bearerToken)"
        ]
        
        let (data, _) = try await session.data(for: req)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Model.self, from: data)
    }
    
}
