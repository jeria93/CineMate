//
//  Movie+Helpers.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

extension Array where Element == Movie {
    /// Removes duplicate movies based on their `id`.
    func removingDuplicateIDs() -> [Movie] {
        Dictionary(grouping: self, by: \.id)
            .compactMap { $0.value.first }
    }

    /// Filters out movies that already exist in the given ID set.
    func excluding(alreadySeenIDs: Set<Int>) -> [Movie] {
        self.filter { !alreadySeenIDs.contains($0.id) }
    }
}
