//
//  FavoritesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-12.
//

import Foundation
import SwiftUI

/// SwiftUI previews for **FavoritesView**.
/// Injects ready-made view models from `PreviewFactory` and wraps the view
/// in `withPreviewNavigation()` so navigation works inside previews.
extension FavoritesView {

    /// Default preview: both tabs wired; people contains a few items.
    static var previewDefault: some View {
        FavoritesView(
            moviesVM: PreviewFactory.favoritesViewModel(),
            peopleVM: PreviewFactory.favoritePeopleDefaultVM()
        )
        .withPreviewNavigation()
    }

    /// Preview focused on Movies: People tab is empty.
    static var previewMoviesOnly: some View {
        FavoritesView(
            moviesVM: PreviewFactory.favoritesViewModel(),
            peopleVM: PreviewFactory.favoritePeopleEmptyVM()
        )
        .withPreviewNavigation()
    }

    /// Preview focused on People: many favorite people preloaded.
    static var previewPeopleMany: some View {
        FavoritesView(
            moviesVM: PreviewFactory.favoritesViewModel(),
            peopleVM: PreviewFactory.favoritePeopleManyVM()
        )
        .withPreviewNavigation()
    }
}
