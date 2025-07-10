//
//  DiscoverSortMenu+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Provides preview configurations for `DiscoverSortMenu`.
/// Used to preview the sort menu with different selected sort options.
extension DiscoverSortMenu {

    /// A preview with the default sort option (.popularityDesc).
    static var previewDefault: some View {
        DiscoverSortMenu(selectedSort: .constant(.popularityDesc))
    }

    /// A preview with a different sort option (.popularityAsc) to test UI appearance.
    static var previewEmpty: some View {
        DiscoverSortMenu(selectedSort: .constant(.popularityAsc))
    }
}
