//
//  PaginationManager.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-04.
//

import Foundation

/// Manages pagination logic for features like infinite scrolling in lists.
///
/// Responsibilities:
/// - Tracks the current page, total pages, and loading state.
/// - Prevents duplicate concurrent page fetches (in-flight protection).
/// - Provides a simple API to start, finish, and reset pagination.
///
/// Usage Example:
/// ```swift
/// if paginationManager.startFetchingNextPage() {
///     let nextPage = paginationManager.state.currentPage + 1
///     Task {
///         let response = try await repository.fetchMovies(page: nextPage)
///         movies.append(contentsOf: response.movies)
///         paginationManager.finishFetching(page: nextPage, totalPages: response.totalPages)
///     }
/// }
/// ```
final class PaginationManager {
    /// Internal state tracking the current page, total pages, and fetch status.
    private(set) var state = PaginationState()

    /// Returns `true` if there are more pages to fetch.
    var hasMorePages: Bool { state.hasMorePages }

    /// Returns `true` if a page fetch is currently in progress.
    var isFetching: Bool { state.isFetchingNextPage }

    /// Attempts to start fetching the next page.
    /// - Returns: `true` if fetching can start, otherwise `false`.
    @discardableResult
    func startFetchingNextPage() -> Bool {
        guard state.hasMorePages, !state.isFetchingNextPage else { return false }
        state.isFetchingNextPage = true
        return true
    }

    /// Marks the completion of a page fetch and updates the pagination state.
    /// - Parameters:
    ///   - page: The current page number after fetching.
    ///   - totalPages: The total number of pages available.
    func finishFetching(page: Int, totalPages: Int) {
        state.isFetchingNextPage = false
        state.currentPage = page
        state.totalPages = totalPages
    }

    /// Resets the pagination to its initial state (page 1, no loading).
    func reset() {
        state.reset()
    }
}
