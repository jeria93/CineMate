//
//  MovieLoaderHelper.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

/// Utility for managing movie loading operations and deduplication.
///
/// Helps ensure:
/// - No duplicate movie IDs are appended
/// - Only new, unseen movies are added to the list
/// - Seen IDs are tracked to prevent repeated data
struct MovieLoaderHelper {

    /// Appends unique and unseen movies to the current list.
    ///
    /// - Parameters:
    ///   - currentMovies: The list of already loaded movies (mutable).
    ///   - newMovies: The list of newly fetched movies to process.
    ///   - seenIDs: A set tracking all movie IDs that have been loaded.
    static func appendNewMovies(
        currentMovies: inout [Movie],
        newMovies: [Movie],
        seenIDs: inout Set<Int>
    ) {
        let filtered = newMovies
            .removingDuplicateIDs()
            .excluding(alreadySeenIDs: seenIDs)

        currentMovies.append(contentsOf: filtered)
        filtered.forEach { seenIDs.insert($0.id) }
    }
}
