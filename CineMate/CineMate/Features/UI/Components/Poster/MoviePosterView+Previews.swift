//
//  MoviePosterView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

/// Previews for `MoviePosterView`
///
/// - `previewDefault`: Displays a poster with full data (Dune)
/// - `previewMissingPoster`: Simulates a case where poster is missing (uses fallback UI)
extension MoviePosterView {

    /// Preview for poster with valid image
    static var previewDefault: some View {
        PreviewID.reset()
        return MoviePosterView(movie: MoviePosterViewPreviewData.dune)
    }

    /// Preview for poster with missing image
    static var previewMissingPoster: some View {
        PreviewID.reset()
        return MoviePosterView(movie: MoviePosterViewPreviewData.duneNoPoster)
    }
}
