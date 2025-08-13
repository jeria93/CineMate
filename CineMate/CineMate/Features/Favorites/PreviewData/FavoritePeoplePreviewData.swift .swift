//
//  FavoritePeoplePreviewData.swift .swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Static mock data for favorite people used in SwiftUI previews.
/// Keeps preview IDs deterministic via `PreviewID`.
enum FavoritePeoplePreviewData {

    /// Empty data set (drives empty state UIs).
    static func empty() -> [PersonRef] { [] }

    /// A small, human-readable set of sample people.
    /// - Returns: 3 well-known names for quick visual checks.
    static func few() -> [PersonRef] {
        PreviewID.reset()
        return [
            .init(id: PreviewID.next(), name: "Emma Stone",        profilePath: nil),
            .init(id: PreviewID.next(), name: "Leonardo DiCaprio", profilePath: nil),
            .init(id: PreviewID.next(), name: "Greta Gerwig",      profilePath: nil)
        ]
    }

    /// A larger list to stress-test grid layout and scrolling.
    /// - Returns: 20 placeholder people with unique IDs.
    static func many() -> [PersonRef] {
        PreviewID.reset()
        return (1...20).map { i in
            .init(id: PreviewID.next(), name: "Person \(i)", profilePath: nil)
        }
    }
}
