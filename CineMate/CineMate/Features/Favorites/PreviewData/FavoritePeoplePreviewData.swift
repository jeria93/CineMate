//
//  FavoritePeoplePreviewData.swift
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
        [
            .init(id: PreviewID.scoped(.favorites, 1), name: "Emma Stone", profilePath: nil),
            .init(id: PreviewID.scoped(.favorites, 2), name: "Leonardo DiCaprio", profilePath: nil),
            .init(id: PreviewID.scoped(.favorites, 3), name: "Greta Gerwig", profilePath: nil)
        ]
    }

    /// A larger list to stress-test grid layout and scrolling.
    /// - Returns: 20 placeholder people with unique IDs.
    static func many() -> [PersonRef] {
        (1...20).map { index in
            .init(
                id: PreviewID.scoped(.favorites, 100 + index),
                name: "Person \(index)",
                profilePath: nil
            )
        }
    }
}
