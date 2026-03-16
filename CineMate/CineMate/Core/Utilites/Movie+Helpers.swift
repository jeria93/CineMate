//
//  Movie+Helpers.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import Foundation

private func uniqueByID<Item, ID: Hashable>(_ items: [Item], id: KeyPath<Item, ID>) -> [Item] {
    var seenIDs = Set<ID>()
    return items.filter { seenIDs.insert($0[keyPath: id]).inserted }
}

extension Array where Element == Movie {
    /// Removes duplicate movies based on their `id`.
    func removingDuplicateIDs() -> [Movie] {
        uniqueByID(self, id: \.id)
    }

    /// Filters out movies that already exist in the given ID set.
    func excluding(alreadySeenIDs: Set<Int>) -> [Movie] {
        filter { !alreadySeenIDs.contains($0.id) }
    }
}

extension Array where Element == PersonRef {
    /// Removes duplicate people based on their `id`.
    func removingDuplicateIDs() -> [PersonRef] {
        uniqueByID(self, id: \.id)
    }
}
