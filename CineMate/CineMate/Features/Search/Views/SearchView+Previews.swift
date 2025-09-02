//
//  SearchView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Provides SwiftUI previews for all primary `SearchView` states.
/// Uses `PreviewFactory` to supply deterministic `SearchViewModel` and
/// a mocked `FavoriteMoviesViewModel` for consistent layout and behavior.
extension SearchView {

    /// Results state: valid query with a populated list.
    static var previewDefault: some View {
        SearchView(
            searchViewModel: PreviewFactory.searchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    /// Empty state: valid query that returns no results.
    static var previewEmpty: some View {
        SearchView(
            searchViewModel: PreviewFactory.emptySearchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    /// Loading state: shows spinner while searching.
    static var previewLoading: some View {
        SearchView(
            searchViewModel: PreviewFactory.loadingSearchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    /// Error state: shows an error message after a failed search.
    static var previewError: some View {
        SearchView(
            searchViewModel: PreviewFactory.errorSearchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    /// Prompt state: empty input prompting the user to start typing.
    static var previewPrompt: some View {
        SearchView(
            searchViewModel: PreviewFactory.promptSearchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }

    /// Validation state: invalid query with a visible validation message.
    static var previewValidation: some View {
        SearchView(
            searchViewModel: PreviewFactory.invalidSearchViewModel(),
            favoriteViewModel: PreviewFactory.favoritesViewModel()
        )
    }
}
