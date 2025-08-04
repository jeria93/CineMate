//
//  SearchView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI

/// Provides SwiftUI previews for all main SearchView states.
/// Uses `PreviewFactory` for consistent mock data and layout testing.
extension SearchView {

    /// Preview showing a list of search results for a valid query.
    static var previewDefault: some View {
        SearchView(viewModel: PreviewFactory.searchViewModel())
    }

    /// Preview showing the empty state when no results are found.
    static var previewEmpty: some View {
        SearchView(viewModel: PreviewFactory.emptySearchViewModel())
    }

    /// Preview showing a loading spinner while searching.
    static var previewLoading: some View {
        SearchView(viewModel: PreviewFactory.loadingSearchViewModel())
    }

    /// Preview showing an error message after a failed search.
    static var previewError: some View {
        SearchView(viewModel: PreviewFactory.errorSearchViewModel())
    }

    /// Preview showing a prompt when the search field is empty.
    static var previewPrompt: some View {
        SearchView(viewModel: PreviewFactory.promptSearchViewModel())
    }

    /// Preview showing a validation error for an invalid query.
    static var previewValidation: some View {
        SearchView(viewModel: PreviewFactory.invalidSearchViewModel())
    }
}
