//
//  PreviewID.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-15.
//

import Foundation

/// A helper to generate unique IDs for SwiftUI previews
enum PreviewID {
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
}
