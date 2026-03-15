//
//  PreviewID.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-15.
//

import Foundation

/// A helper to generate unique IDs for SwiftUI previews
enum PreviewID {
    enum Namespace: Int {
        case sharedMovies = 100_000
        case discover = 110_000
        case favorites = 120_000
        case people = 130_000
        case movieCredits = 140_000
        case movieDetail = 150_000
        case movieComponents = 160_000
        case peopleComponents = 170_000
        case genre = 180_000
        case ui = 190_000
    }

    private static var currentID: Int = 100_000

    /// Returns the next available unique ID
    static func next() -> Int {
        defer { currentID += 1 }
        return currentID
    }

    /// Resets the ID generator (optional, mostly for testing)
    static func reset() {
        currentID = 100_000
    }

    /// Returns a deterministic ID scoped to a preview namespace.
    static func scoped(_ namespace: Namespace, _ offset: Int) -> Int {
        namespace.rawValue + offset
    }
}
