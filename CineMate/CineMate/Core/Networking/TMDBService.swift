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

    private enum QueryName {
        static let page = "page"
        static let region = "region"
        static let query = "query"
    }

    private enum SecretKey {
        static let bearerToken = "TMDB_BEARER_TOKEN"
    }

    private let baseURL: URL
    private let session: URLSession
    private let decoderFactory: () -> JSONDecoder

    init(
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        session: URLSession = .shared,
        decoderFactory: @escaping () -> JSONDecoder = TMDBService.makeDecoder
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoderFactory = decoderFactory
    }

    private var userRegion: String {
        Locale.current.region?.identifier ?? "US"
    }

    private var isPreviewEnvironment: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
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
        let queryItems = regionQueryItems(region) + [pageQueryItem(page)]
        return try await request(endpoint: endpoint, queryItems: queryItems)
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

    func fetchRecommendedMovies(for movieId: Int, page: Int = 1) async throws -> [Movie] {
        try await requestMovieList(
            endpoint: .recommendations(movieId),
            queryItems: [pageQueryItem(page)]
        )
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProvidersResponse {
        try await request(endpoint: .watchProviders(movieId))
    }

    func fetchWatchProviderRegion(for movieId: Int) async throws -> WatchProviderRegion {
        let response = try await fetchWatchProviders(for: movieId)
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
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: QueryName.query, value: query),
            pageQueryItem(page)
        ]
        return try await request(endpoint: .search, queryItems: queryItems)
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        try await requestMovieList(endpoint: .discover, queryItems: filters)
    }

    // MARK: - Misc
    func fetchNowPlayingMovies() async throws -> [Movie] {
        try await requestMovieList(endpoint: .nowPlaying)
    }

    func fetchGenres() async throws -> [Genre] {
        let response: GenreResponse = try await request(endpoint: .movieGenres)
        return response.genres
    }

    // MARK: - Helpers
    private func regionQueryItems(_ region: String?) -> [URLQueryItem] {
        let resolvedRegion = region ?? userRegion
        return [URLQueryItem(name: QueryName.region, value: resolvedRegion)]
    }

    private func pageQueryItem(_ page: Int) -> URLQueryItem {
        URLQueryItem(name: QueryName.page, value: "\(max(1, page))")
    }

    // MARK: - Generic Request
    func request<Model: Decodable>(endpoint: TMDBEndpoint, queryItems: [URLQueryItem] = []) async throws -> Model {
        let data = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return try decode(Model.self, from: data)
    }

    private func requestMovieList(
        endpoint: TMDBEndpoint,
        queryItems: [URLQueryItem] = []
    ) async throws -> [Movie] {
        let result: MovieResult = try await request(endpoint: endpoint, queryItems: queryItems)
        return result.results
    }

    private func performRequest(
        endpoint: TMDBEndpoint,
        queryItems: [URLQueryItem]
    ) async throws -> Data {
        guard !isPreviewEnvironment else {
            throw TMDBError.previewRequestBlocked
        }

        let bearerToken = try SecretManager.load(SecretKey.bearerToken)
        let request = try endpoint.makeRequest(
            baseURL: baseURL,
            queryItems: queryItems,
            bearerToken: bearerToken
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw mapServerError(statusCode: httpResponse.statusCode, data: data)
            }

            guard !data.isEmpty else {
                throw TMDBError.emptyResponse
            }
            return data
        } catch let error as TMDBError {
            throw error
        } catch let error as URLError {
            throw TMDBError.networkFailure(error)
        } catch {
            throw TMDBError.unknown
        }
    }

    private func decode<Model: Decodable>(_ type: Model.Type, from data: Data) throws -> Model {
        do {
            return try decoderFactory().decode(type, from: data)
        } catch {
            throw TMDBError.decodingFailed
        }
    }

    private func mapServerError(statusCode: Int, data: Data) -> TMDBError {
        if let payload = try? decoderFactory().decode(TMDBErrorPayload.self, from: data),
           payload.statusMessage != nil || payload.statusCode != nil {
            return .tmdbError(
                statusCode: payload.statusCode ?? statusCode,
                message: payload.statusMessage
            )
        }
        return .serverError(statusCode)
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

private struct TMDBErrorPayload: Decodable {
    let statusCode: Int?
    let statusMessage: String?
}
