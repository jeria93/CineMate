//
//  DiscoverContentView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Preview states for `DiscoverContentView` to simulate different UI conditions in Xcode canvas.
/// Each static var returns a `DiscoverContentView` with a specific mocked ViewModel state.
extension DiscoverContentView {

    /// Shows DiscoverContentView with a list of movies
    static var previewDefault: some View {
        DiscoverContentView(viewModel: PreviewFactory.discoverViewModel())
    }

    /// Shows DiscoverContentView in a loading state
    static var previewLoading: some View {
        DiscoverContentView(viewModel: PreviewFactory.loadingDiscoverViewModel())
    }

    /// Shows DiscoverContentView with an empty result set
    static var previewEmpty: some View {
        DiscoverContentView(viewModel: PreviewFactory.emptyDiscoverViewModel())
    }

    /// Shows DiscoverContentView in an error state
    static var previewError: some View {
        DiscoverContentView(viewModel: PreviewFactory.errorDiscoverViewModel())
    }
}
