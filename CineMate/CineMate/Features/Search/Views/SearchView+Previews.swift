//
//  SearchView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-05.
//

import SwiftUI


extension SearchView {

    static var previewDefault: some View {
        SearchView(viewModel: PreviewFactory.searchViewModel())
    }

    static var previewEmpty: some View {
        SearchView(viewModel: PreviewFactory.emptySearchViewModel())
    }

    static var previewLoading: some View {
        SearchView(viewModel: PreviewFactory.loadingSearchViewModel())
    }

    static var previewError: some View {
        SearchView(viewModel: PreviewFactory.errorSearchViewModel())
    }

    static var previewPrompt: some View {
        SearchView(viewModel: PreviewFactory.promptSearchViewModel())
    }

    static var previewValidation: some View {
        SearchView(viewModel: PreviewFactory.invalidSearchViewModel())
    }
}
