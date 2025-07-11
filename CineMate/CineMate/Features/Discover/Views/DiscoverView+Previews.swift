//
//  DiscoverView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-09.
//

import SwiftUI

extension DiscoverView {
    static var previewDefault: some View {
        DiscoverView(viewModel: PreviewFactory.discoverViewModel())
    }

    static var previewLoading: some View {
        DiscoverView(viewModel: PreviewFactory.loadingDiscoverViewModel())
    }

    static var previewEmpty: some View {
        DiscoverView(viewModel: PreviewFactory.emptyDiscoverViewModel())
    }

    static var previewError: some View {
        DiscoverView(viewModel: PreviewFactory.errorDiscoverViewModel())
    }

    static var previewOneSection: some View {
        DiscoverView(viewModel: PreviewFactory.oneSectionOnlyDiscoverViewModel())
    }
}
