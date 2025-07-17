//
//  PersonMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

/// Preview variations for `PersonMovieCardView`.
///
/// Simulates standard, missing poster, and missing title states.
extension PersonMovieCardView {

    /// Preview with a full movie credit.
    static var preview: some View {
        PersonMovieCardView(movie: PersonMovieCardPreviewData.standard)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview where posterPath is missing (fallback image shown).
    static var previewMissingPoster: some View {
        PersonMovieCardView(movie: PersonMovieCardPreviewData.missingPoster)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview where title is nil (fallback "Untitled" shown).
    static var previewMissingTitle: some View {
        PersonMovieCardView(movie: PersonMovieCardPreviewData.missingTitle)
            .padding()
            .background(Color(.systemBackground))
    }
}
