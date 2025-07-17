//
//  SeeAllMoviesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

/// Preview variations for `SeeAllMoviesView`
///
/// These previews simulate different UI states to help visualize:
/// - Normal loaded list (`previewDefault`)
/// - Loading state (`previewLoading`)
/// - Error state (`previewError`)
/// - Empty state (`previewEmpty`)
///
/// Each uses a corresponding mock `SeeAllMoviesViewModel` from `PreviewFactory+SeeAllMovies`.
extension SeeAllMoviesView {

    /// Shows a populated list of movies (mock data)
    static var previewDefault: some View {
        PreviewFactory.resetAllPreviewData()
        return SeeAllMoviesView(
            title: "Popular Movies",
            viewModel: .preview
        )
    }

    /// Simulates a loading state with spinner
    static var previewLoading: some View {
        SeeAllMoviesView(
            title: "Loading...",
            viewModel: .loading
        )
    }

    /// Simulates an error state with retry button
    static var previewError: some View {
        SeeAllMoviesView(
            title: "Error",
            viewModel: .error
        )
    }

    /// Simulates an empty state with no movies returned
    static var previewEmpty: some View {
        SeeAllMoviesView(
            title: "Empty",
            viewModel: .empty
        )
    }
}
