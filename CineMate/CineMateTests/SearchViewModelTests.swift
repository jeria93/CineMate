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
