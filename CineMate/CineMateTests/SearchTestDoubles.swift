import Foundation
@testable import CineMate

enum SearchTestError: Error, Equatable {
    case forcedFailure
    case unimplemented
}

actor SearchTestRepository: MovieProtocol {
    private struct SearchKey: Hashable {
        let query: String
        let page: Int
    }

    private var queuedResults: [SearchKey: [Result<MovieResult, Error>]] = [:]
    private var delaysNanos: [SearchKey: UInt64] = [:]
    private var callCounts: [SearchKey: Int] = [:]

    func enqueueSearchResult(_ result: Result<MovieResult, Error>, query: String, page: Int = 1) {
        let key = SearchKey(query: query, page: page)
        queuedResults[key, default: []].append(result)
    }

    func setSearchDelay(_ nanos: UInt64, query: String, page: Int = 1) {
        let key = SearchKey(query: query, page: page)
        delaysNanos[key] = nanos
    }

    func searchCallCount(query: String, page: Int = 1) -> Int {
        let key = SearchKey(query: query, page: page)
        return callCounts[key, default: 0]
    }

    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        throw SearchTestError.unimplemented
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        throw SearchTestError.unimplemented
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        throw SearchTestError.unimplemented
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        throw SearchTestError.unimplemented
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        throw SearchTestError.unimplemented
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderAvailability {
        throw SearchTestError.unimplemented
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        throw SearchTestError.unimplemented
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        throw SearchTestError.unimplemented
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        throw SearchTestError.unimplemented
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        let key = SearchKey(query: query, page: page)
        callCounts[key, default: 0] += 1

        if let delay = delaysNanos[key], delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }

        if var queue = queuedResults[key], !queue.isEmpty {
            let result = queue.removeFirst()
            queuedResults[key] = queue
            return try result.get()
        }

        return MovieResult(page: max(1, page), results: [], totalPages: 1, totalResults: 0)
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        throw SearchTestError.unimplemented
    }

    func fetchNowPlayingMovies(page: Int, region: String?) async throws -> MovieResult {
        throw SearchTestError.unimplemented
    }

    func fetchGenres() async throws -> [Genre] {
        throw SearchTestError.unimplemented
    }
}

enum SearchTestMovieFactory {
    static func movie(id: Int, title: String) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: nil,
            genres: nil
        )
    }

    static func page(_ page: Int, totalPages: Int, movies: [Movie]) -> MovieResult {
        MovieResult(page: page, results: movies, totalPages: totalPages, totalResults: movies.count)
    }
}

enum SearchTestWait {
    static func ms(_ value: UInt64) async {
        try? await Task.sleep(nanoseconds: value * 1_000_000)
    }
}
