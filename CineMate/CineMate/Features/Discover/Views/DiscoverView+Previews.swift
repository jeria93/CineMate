//
//  DiscoverView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

extension DiscoverView {

    /// A default state with popular movies
    static var previewDefault: some View {
        DiscoverView(viewModel: PreviewFactory.discoverViewModel())
    }

    /// A loading state for the DiscoverView
    static var previewLoading: some View {
        DiscoverView(viewModel: PreviewFactory.loadingDiscoverViewModel())
    }

    /// An empty result state
    static var previewEmpty: some View {
        DiscoverView(viewModel: PreviewFactory.emptyDiscoverViewModel())
    }

    /// An error state (e.g. network failure)
    static var previewError: some View {
        DiscoverView(viewModel: PreviewFactory.errorDiscoverViewModel())
    }
}
