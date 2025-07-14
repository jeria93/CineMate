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

    static var previewDefault: some View {
        MoviePosterView(movie: MoviePosterPreviewData.dune)
    }

    static var previewMissingPoster: some View {
        MoviePosterView(movie: MoviePosterPreviewData.duneNoPoster)
    }
}
