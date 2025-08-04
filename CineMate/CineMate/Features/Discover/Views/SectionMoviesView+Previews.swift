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
            viewModel: .preview,
            title: "Popular Movies"
        )
    }

    /// Simulates a loading state with spinner
    static var previewLoading: some View {
        SeeAllMoviesView(
            viewModel: .loading,
            title: "Loading…"
        )
    }

    /// Simulates an error state with retry button
    static var previewError: some View {
        SeeAllMoviesView(
            viewModel: .error,
            title: "Error"
        )
    }

    /// Simulates an empty state with no movies returned
    static var previewEmpty: some View {
        SeeAllMoviesView(
            viewModel: .empty,
            title: "Empty"
        )
    }
}
