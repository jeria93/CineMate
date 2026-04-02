import XCTest
@testable import CineMate

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testDebounceIgnoresStaleResponses() async {
        let repository = SearchTestRepository()

        await repository.enqueueSearchResult(
            .success(
                SearchTestMovieFactory.page(
                    1,
                    totalPages: 1,
                    movies: [SearchTestMovieFactory.movie(id: 1, title: "Star")]
                )
            ),
            query: "star"
        )
        await repository.setSearchDelay(300_000_000, query: "star")

        await repository.enqueueSearchResult(
            .success(
                SearchTestMovieFactory.page(
                    1,
                    totalPages: 1,
                    movies: [SearchTestMovieFactory.movie(id: 2, title: "Stardust")]
                )
            ),
            query: "stardust"
        )
        await repository.setSearchDelay(20_000_000, query: "stardust")

        let viewModel = SearchViewModel(
            repository: repository,
            isPreviewEnvironment: false,
            debounceDelayNanos: 50_000_000
        )

        viewModel.query = "star"
        await SearchTestWait.ms(80)
        viewModel.query = "stardust"

        await SearchTestWait.ms(500)

        let starCalls = await repository.searchCallCount(query: "star")
        let stardustCalls = await repository.searchCallCount(query: "stardust")

        XCTAssertEqual(starCalls, 1)
        XCTAssertEqual(stardustCalls, 1)
        XCTAssertEqual(viewModel.results.map(\.title), ["Stardust"])
        XCTAssertEqual(viewModel.trimmedQuery, "stardust")
        XCTAssertEqual(viewModel.state, .results)
    }

    func testInFlightGuardPreventsDuplicateManualSearch() async {
        let repository = SearchTestRepository()
        await repository.enqueueSearchResult(
            .success(
                SearchTestMovieFactory.page(
                    1,
                    totalPages: 1,
                    movies: [SearchTestMovieFactory.movie(id: 10, title: "Inception")]
                )
            ),
            query: "inception"
        )
        await repository.setSearchDelay(200_000_000, query: "inception")

        let viewModel = SearchViewModel(repository: repository, isPreviewEnvironment: false)

        async let first: Void = viewModel.search("inception")
        async let second: Void = viewModel.search("inception")
        _ = await (first, second)

        let calls = await repository.searchCallCount(query: "inception")
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(viewModel.state, .results)
    }

    func testPaginationLoadsOnlyNearEnd() async {
        let repository = SearchTestRepository()

        let firstPageMovies = (1...8).map { SearchTestMovieFactory.movie(id: $0, title: "Movie \($0)") }
        let secondPageMovies = [
            SearchTestMovieFactory.movie(id: 9, title: "Movie 9"),
            SearchTestMovieFactory.movie(id: 10, title: "Movie 10")
        ]

        await repository.enqueueSearchResult(
            .success(SearchTestMovieFactory.page(1, totalPages: 2, movies: firstPageMovies)),
            query: "batman",
            page: 1
        )
        await repository.enqueueSearchResult(
            .success(SearchTestMovieFactory.page(2, totalPages: 2, movies: secondPageMovies)),
            query: "batman",
            page: 2
        )

        let viewModel = SearchViewModel(repository: repository, isPreviewEnvironment: false)
        await viewModel.search("batman")

        await viewModel.loadNextPageIfNeeded(currentItem: viewModel.results[1])
        await SearchTestWait.ms(80)
        let nonTriggerCalls = await repository.searchCallCount(query: "batman", page: 2)
        XCTAssertEqual(nonTriggerCalls, 0)

        await viewModel.loadNextPageIfNeeded(currentItem: viewModel.results[6])
        await SearchTestWait.ms(120)

        let triggerCalls = await repository.searchCallCount(query: "batman", page: 2)
        XCTAssertEqual(triggerCalls, 1)
        XCTAssertEqual(viewModel.results.count, 10)
        XCTAssertEqual(viewModel.state, .results)
    }

    func testRetryRecoversFromNetworkError() async {
        let repository = SearchTestRepository()

        await repository.enqueueSearchResult(
            .failure(SearchTestError.forcedFailure),
            query: "alien",
            page: 1
        )
        await repository.enqueueSearchResult(
            .success(
                SearchTestMovieFactory.page(
                    1,
                    totalPages: 1,
                    movies: [SearchTestMovieFactory.movie(id: 42, title: "Alien")]
                )
            ),
            query: "alien",
            page: 1
        )

        let viewModel = SearchViewModel(repository: repository, isPreviewEnvironment: false)

        await viewModel.search("alien")
        XCTAssertEqual(viewModel.state, .networkError)
        XCTAssertEqual(viewModel.error, .networkFailure)

        await viewModel.retryLastSearch()
        XCTAssertEqual(viewModel.state, .results)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.results.map(\.title), ["Alien"])

        let calls = await repository.searchCallCount(query: "alien", page: 1)
        XCTAssertEqual(calls, 2)
    }

    func testGuestModeBlocksAutoAndManualSearchUntilUnlocked() async {
        let repository = SearchTestRepository()
        await repository.enqueueSearchResult(
            .success(
                SearchTestMovieFactory.page(
                    1,
                    totalPages: 1,
                    movies: [SearchTestMovieFactory.movie(id: 7, title: "Matrix")]
                )
            ),
            query: "matrix"
        )

        let viewModel = SearchViewModel(
            repository: repository,
            isPreviewEnvironment: false,
            debounceDelayNanos: 50_000_000
        )

        viewModel.configureGuestMode(isGuest: true)
        viewModel.query = "matrix"
        await SearchTestWait.ms(120)
        await viewModel.search("matrix")

        let guestCalls = await repository.searchCallCount(query: "matrix")
        XCTAssertEqual(guestCalls, 0)
        XCTAssertEqual(viewModel.state, .prompt)

        viewModel.configureGuestMode(isGuest: false)
        await viewModel.search("matrix")

        let unlockedCalls = await repository.searchCallCount(query: "matrix")
        XCTAssertEqual(unlockedCalls, 1)
        XCTAssertEqual(viewModel.state, .results)
    }

    func testPreviewPathNeverHitsRepository() async {
        let repository = SearchTestRepository()
        let viewModel = SearchViewModel(repository: repository, isPreviewEnvironment: true)

        await viewModel.search("star")

        let calls = await repository.searchCallCount(query: "star", page: 1)
        XCTAssertEqual(calls, 0)
        XCTAssertFalse(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.state, .results)
    }
}

@MainActor
final class DiscoverViewModelRoutingTests: XCTestCase {
    func testSelectedGenreRoutesAllSectionsThroughDiscover() async {
        let repository = DiscoverRoutingRepository()
        let viewModel = DiscoverViewModel(repository: repository)

        viewModel.selectedGenreId = 35 // Comedy
        await viewModel.filterSections()

        let snapshot = await repository.snapshot()

        XCTAssertEqual(snapshot.categoryCalls.count, 0)
        XCTAssertEqual(snapshot.nowPlayingCallCount, 0)
        XCTAssertEqual(snapshot.discoverCalls.count, DiscoverSectionKind.allCases.count)

        let genreValues = snapshot.discoverCalls.compactMap { queryItems in
            queryItems.first(where: { $0.name == DiscoverQueryKey.withGenres })?.value
        }

        XCTAssertEqual(genreValues.count, DiscoverSectionKind.allCases.count)
        XCTAssertEqual(genreValues.filter { $0.contains("35") }.count, DiscoverSectionKind.allCases.count)

        let horrorGenreValue = genreValues.first { value in
            value.contains("27") && value.contains("35")
        }
        XCTAssertNotNil(horrorGenreValue)

        let topRatedQuery = snapshot.discoverCalls.first { queryItems in
            queryItems.first(where: { $0.name == DiscoverQueryKey.sortBy })?.value == SortOption.voteAverageDesc.rawValue
        }
        let minVoteCount = topRatedQuery?.first(where: { $0.name == DiscoverQueryKey.minVoteCount })?.value
        XCTAssertEqual(minVoteCount, "200")
    }

    func testNoGenreUsesDedicatedEndpointsAndDiscoverOnlyForHorror() async {
        let repository = DiscoverRoutingRepository()
        let viewModel = DiscoverViewModel(repository: repository)

        await viewModel.fetchAllSections(forceReload: true)
        let snapshot = await repository.snapshot()

        XCTAssertEqual(snapshot.nowPlayingCallCount, 1)
        XCTAssertEqual(snapshot.discoverCalls.count, 1)

        let categories = snapshot.categoryCalls.map(categoryKey).sorted()
        XCTAssertEqual(
            categories,
            [
                categoryKey(.popular),
                categoryKey(.topRated),
                categoryKey(.trending),
                categoryKey(.upcoming)
            ].sorted()
        )

        let horrorCall = snapshot.discoverCalls.first
        let horrorGenres = horrorCall?.first(where: { $0.name == DiscoverQueryKey.withGenres })?.value
        XCTAssertEqual(horrorGenres, "27")
    }

    func testSeeAllSourceUsesDiscoverWhenGenreIsSelected() {
        let repository = DiscoverRoutingRepository()
        let viewModel = DiscoverViewModel(repository: repository)

        viewModel.selectedGenreId = 28 // Action
        let source = viewModel.seeAllSource(for: .topRated)

        guard case .discover(let filter) = source else {
            return XCTFail("Expected discover source for selected genre.")
        }
        XCTAssertEqual(filter.withGenres, [28])
    }

    func testSeeAllSourceUsesCategoryOrNowPlayingWithoutGenre() {
        let repository = DiscoverRoutingRepository()
        let viewModel = DiscoverViewModel(repository: repository)

        if case .category(let category) = viewModel.seeAllSource(for: .topRated) {
            XCTAssertEqual(category, .topRated)
        } else {
            XCTFail("Expected category source for top rated without genre.")
        }

        if case .nowPlaying = viewModel.seeAllSource(for: .nowPlaying) {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected nowPlaying source without genre.")
        }

        if case .discover(let filter) = viewModel.seeAllSource(for: .horror) {
            XCTAssertEqual(filter.withGenres, [27])
        } else {
            XCTFail("Expected discover source for horror without genre.")
        }
    }
}

private actor DiscoverRoutingRepository: MovieProtocol {
    struct Snapshot {
        let discoverCalls: [[URLQueryItem]]
        let categoryCalls: [MovieCategory]
        let nowPlayingCallCount: Int
    }

    private enum RepositoryError: Error {
        case unimplemented
    }

    private var discoverCalls: [[URLQueryItem]] = []
    private var categoryCalls: [MovieCategory] = []
    private var nowPlayingCallCount = 0
    private var nextMovieID = 1

    func snapshot() -> Snapshot {
        Snapshot(
            discoverCalls: discoverCalls,
            categoryCalls: categoryCalls,
            nowPlayingCallCount: nowPlayingCallCount
        )
    }

    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        categoryCalls.append(category)
        return MovieResult(
            page: page,
            results: [makeMovie(title: "\(category.displayName) \(page)")],
            totalPages: 2,
            totalResults: 2
        )
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        throw RepositoryError.unimplemented
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        throw RepositoryError.unimplemented
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        throw RepositoryError.unimplemented
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        throw RepositoryError.unimplemented
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderAvailability {
        throw RepositoryError.unimplemented
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        throw RepositoryError.unimplemented
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        throw RepositoryError.unimplemented
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        throw RepositoryError.unimplemented
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        throw RepositoryError.unimplemented
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        discoverCalls.append(filters)
        return [makeMovie(title: "Discover \(discoverCalls.count)")]
    }

    func fetchNowPlayingMovies(page: Int, region: String?) async throws -> MovieResult {
        nowPlayingCallCount += 1
        return MovieResult(
            page: max(1, page),
            results: [makeMovie(title: "Now Playing \(page)")],
            totalPages: 2,
            totalResults: 2
        )
    }

    func fetchGenres() async throws -> [Genre] {
        []
    }

    private func makeMovie(title: String) -> Movie {
        defer { nextMovieID += 1 }
        return Movie(
            id: nextMovieID,
            title: title,
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: nil,
            genres: nil
        )
    }
}

@MainActor
final class GenreDetailViewModelEndpointTests: XCTestCase {
    func testRefreshUsesGenreScopedHighlightAndListQueries() async {
        let repository = GenreDetailRoutingRepository()
        let viewModel = GenreDetailViewModel(genreId: 28, repository: repository)

        await viewModel.refresh()
        let calls = await repository.snapshot()

        XCTAssertEqual(calls.count, 4)
        XCTAssertTrue(calls.allSatisfy { queryValue(DiscoverQueryKey.withGenres, in: $0) == "28" })

        let topRatedCall = calls.first {
            queryValue(DiscoverQueryKey.sortBy, in: $0) == SortOption.voteAverageDesc.rawValue &&
            queryValue(DiscoverQueryKey.minVoteCount, in: $0) == "200"
        }
        XCTAssertNotNil(topRatedCall)

        let newReleaseCall = calls.first {
            queryValue(DiscoverQueryKey.sortBy, in: $0) == SortOption.releaseDateDesc.rawValue &&
            queryValue(DiscoverQueryKey.primaryReleaseDateGTE, in: $0) != nil &&
            queryValue(DiscoverQueryKey.primaryReleaseDateLTE, in: $0) != nil
        }
        XCTAssertNotNil(newReleaseCall)
    }

    func testTopRatedSortAppliesVoteQualityGuards() async throws {
        let repository = GenreDetailRoutingRepository()
        let viewModel = GenreDetailViewModel(genreId: 35, repository: repository)

        viewModel.selectedSort = .topRated
        await viewModel.retryAllMovies()

        let calls = await repository.snapshot()
        XCTAssertEqual(calls.count, 1)

        let query = try XCTUnwrap(calls.first)
        XCTAssertEqual(queryValue(DiscoverQueryKey.withGenres, in: query), "35")
        XCTAssertEqual(queryValue(DiscoverQueryKey.sortBy, in: query), SortOption.voteAverageDesc.rawValue)
        XCTAssertEqual(queryValue(DiscoverQueryKey.minVoteCount, in: query), "200")
        XCTAssertEqual(queryValue(DiscoverQueryKey.minVoteAverage, in: query), "6.0")
        XCTAssertNotNil(queryValue(DiscoverQueryKey.primaryReleaseDateLTE, in: query))
    }

    func testNewestSortExcludesFutureReleaseDates() async throws {
        let repository = GenreDetailRoutingRepository()
        let viewModel = GenreDetailViewModel(genreId: 18, repository: repository)

        viewModel.selectedSort = .newest
        await viewModel.retryAllMovies()

        let calls = await repository.snapshot()
        XCTAssertEqual(calls.count, 1)

        let query = try XCTUnwrap(calls.first)
        XCTAssertEqual(queryValue(DiscoverQueryKey.withGenres, in: query), "18")
        XCTAssertEqual(queryValue(DiscoverQueryKey.sortBy, in: query), SortOption.releaseDateDesc.rawValue)
        XCTAssertNotNil(queryValue(DiscoverQueryKey.primaryReleaseDateLTE, in: query))
        XCTAssertNil(queryValue(DiscoverQueryKey.primaryReleaseDateGTE, in: query))
    }

    private func queryValue(_ name: String, in queryItems: [URLQueryItem]) -> String? {
        queryItems.first(where: { $0.name == name })?.value
    }
}

private actor GenreDetailRoutingRepository: MovieProtocol {
    private enum RepositoryError: Error {
        case unimplemented
    }

    private var discoverCalls: [[URLQueryItem]] = []
    private var nextMovieID = 10_000

    func snapshot() -> [[URLQueryItem]] {
        discoverCalls
    }

    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieResult {
        throw RepositoryError.unimplemented
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetail {
        throw RepositoryError.unimplemented
    }

    func fetchMovieCredits(for movieId: Int) async throws -> MovieCredits {
        throw RepositoryError.unimplemented
    }

    func fetchMovieVideos(for movieId: Int) async throws -> [MovieVideo] {
        throw RepositoryError.unimplemented
    }

    func fetchRecommendedMovies(for movieId: Int) async throws -> [Movie] {
        throw RepositoryError.unimplemented
    }

    func fetchWatchProviders(for movieId: Int) async throws -> WatchProviderAvailability {
        throw RepositoryError.unimplemented
    }

    func fetchPersonDetail(for personId: Int) async throws -> PersonDetail {
        throw RepositoryError.unimplemented
    }

    func fetchPersonMovieCredits(for personId: Int) async throws -> [PersonMovieCredit] {
        throw RepositoryError.unimplemented
    }

    func fetchPersonExternalIDs(for personId: Int) async throws -> PersonExternalIDs {
        throw RepositoryError.unimplemented
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResult {
        throw RepositoryError.unimplemented
    }

    func discoverMovies(filters: [URLQueryItem]) async throws -> [Movie] {
        discoverCalls.append(filters)
        return [makeMovie(title: "Discover \(discoverCalls.count)")]
    }

    func fetchNowPlayingMovies(page: Int, region: String?) async throws -> MovieResult {
        throw RepositoryError.unimplemented
    }

    func fetchGenres() async throws -> [Genre] {
        []
    }

    private func makeMovie(title: String) -> Movie {
        defer { nextMovieID += 1 }
        return Movie(
            id: nextMovieID,
            title: title,
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: nil,
            genres: nil
        )
    }
}

private func categoryKey(_ category: MovieCategory) -> String {
    switch category {
    case .popular:
        return "popular"
    case .topRated:
        return "topRated"
    case .trending:
        return "trending"
    case .upcoming:
        return "upcoming"
    }
}
