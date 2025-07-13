//
//  DiscoverContentView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-12.
//

import SwiftUI

/// Provides inline SwiftUI preview configurations for DiscoverContentView.
/// These previews use mock data from PreviewFactory for different visual states.
extension DiscoverContentView {

    /// Preview showing all content sections populated.
    static var previewDefault: some View {
        DiscoverContentView(viewModel: PreviewFactory.discoverViewModel())
    }

    /// Preview showing only the "Horror" section.
    static var previewHorrorOnly: some View {
        DiscoverContentView(viewModel: PreviewFactory.horrorOnlyDiscoverViewModel())
    }
}
