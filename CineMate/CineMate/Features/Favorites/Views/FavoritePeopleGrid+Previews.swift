//
//  FavoritePeopleGrid+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-13.
//

import SwiftUI

/// SwiftUI previews for **FavoritePeopleGrid**.
/// Uses `PreviewFactory` to supply static `FavoritePeopleViewModel` states.
extension FavoritePeopleGrid {

    /// Grid with a small set of people.
    static var previewFew: some View {
        FavoritePeopleGrid(viewModel: PreviewFactory.favoritePeopleDefaultVM())
    }

    /// Empty grid (shows empty state overlay).
    static var previewEmpty: some View {
        FavoritePeopleGrid(viewModel: PreviewFactory.favoritePeopleEmptyVM())
    }

    /// Grid with many people (tests layout/wrapping).
    static var previewMany: some View {
        FavoritePeopleGrid(viewModel: PreviewFactory.favoritePeopleManyVM())
    }
}
