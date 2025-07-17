//
//  DiscoverMovieRow+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import SwiftUI

/// Previews for `DiscoverMovieRow`
///
/// Simulates different visual scenarios for horizontal movie items:
/// - `previewPoster`: Normal layout with a visible poster.
/// - `previewNoPoster`: Layout when the poster image is missing.
extension DiscoverMovieRow {

    /// Preview with valid poster image.
    ///
    /// Uses mock data from `DiscoverRowPreviewData.dune`.
    /// `PreviewID.reset()` can be omitted if IDs are not used.
    static var previewPoster: some View {
        DiscoverMovieRow(movie: DiscoverRowPreviewData.dune)
            .padding()
    }

    /// Preview with no poster available.
    ///
    /// Uses mock data from `DiscoverRowPreviewData.posterlessMovie`.
    /// Helps visualize fallback UI for missing posters.
    static var previewNoPoster: some View {
        DiscoverMovieRow(movie: DiscoverRowPreviewData.posterlessMovie)
            .padding()
    }
}
