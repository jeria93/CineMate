//
//  DiscoverView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

/// Provides SwiftUI previews for the main DiscoverView.
/// Each preview represents a different loading or data state.
extension DiscoverView {

    /// Preview showing all content sections.
    static var previewDefault: some View {
        DiscoverView(viewModel: PreviewFactory.discoverViewModel())
    }

    /// Preview simulating a loading spinner.
    static var previewLoading: some View {
        DiscoverView(viewModel: PreviewFactory.loadingDiscoverViewModel())
    }

    /// Preview with no content (all sections empty).
    static var previewEmpty: some View {
        DiscoverView(viewModel: PreviewFactory.emptyDiscoverViewModel())
    }
    
    /// Preview showing an error message.
    static var previewError: some View {
        DiscoverView(viewModel: PreviewFactory.errorDiscoverViewModel())
    }

    /// Preview showing only a single section (e.g., "Top Rated").
    static var previewOneSection: some View {
        DiscoverView(viewModel: PreviewFactory.oneSectionOnlyDiscoverViewModel())
    }
}
