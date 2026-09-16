//
//  FavoritePeoplePreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation

/// Favorite-person fixtures for SwiftUI previews.
/// Uses the demo catalog for realistic samples and scoped IDs for grid stress data.
enum FavoritePeoplePreviewData {

    /// Empty data set (drives empty state UIs).
    static func empty() -> [PersonRef] { [] }

    /// A small, human-readable set of sample people.
    /// - Returns: The same 3 people seeded in the portfolio demo.
    static func few() -> [PersonRef] {
        DemoCatalog.seedFavoritePeople
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
