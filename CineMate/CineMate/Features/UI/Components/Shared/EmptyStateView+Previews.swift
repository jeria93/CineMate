//
//  EmptyStateView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import SwiftUI

/// Preview presets for `EmptyStateView`.
///
/// These static previews help visualize different empty states,
/// such as no search results, no favorites, or generic placeholders.
/// Use in `#Preview` blocks for clean and consistent previews.
extension EmptyStateView {
    static var previewNoResults: some View {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or filter options."
        )
    }

    static var previewNoFavorites: some View {
        EmptyStateView(
            systemImage: "heart.slash",
            title: "No Favorites Yet",
            message: "Tap the heart icon to save movies you love.",
            actionTitle: "Browse Movies",
            onAction: { print("Browse tapped") }
        )
    }

    static var previewGeneric: some View {
        EmptyStateView(
            systemImage: "film",
            title: "Nothing to Show",
            message: "There’s no content here at the moment."
        )
    }
}
