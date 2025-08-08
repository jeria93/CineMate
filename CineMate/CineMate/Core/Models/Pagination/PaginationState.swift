//
//  PaginationState.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-04.
//

import Foundation

/// Represents the current pagination state for infinite scrolling or paginated API requests.
///
/// Responsibilities:
/// - Tracks the current page and total pages for a given query.
/// - Indicates if a page fetch is currently in progress.
/// - Provides a computed property to determine if more pages are available.
///
/// Usage:
/// - Reset when starting a new query.
/// - Update `currentPage` and `totalPages` after each successful page fetch.
/// - Check `hasMorePages` before triggering the next page load.
struct PaginationState {

    /// The current page index that has been successfully loaded.
    /// Starts at `1` because most APIs (including TMDB) are 1-based.
    var currentPage = 1

    /// The total number of pages available for the current query.
    /// Defaults to `1` to prevent false positives for `hasMorePages`.
    var totalPages = 1

    /// Indicates whether a next-page fetch is currently in progress.
    /// Helps prevent duplicate concurrent network requests.
    var isFetchingNextPage = false

    /// Returns `true` if more pages are available to fetch.
    /// Returns `false` when `currentPage` >= `totalPages`.
    var hasMorePages: Bool {
        currentPage < totalPages
    }

    /// Resets the pagination state to its initial values (page 1, no loading).
    mutating func reset() {
        currentPage = 1
        totalPages = 1
        isFetchingNextPage = false
    }
}
