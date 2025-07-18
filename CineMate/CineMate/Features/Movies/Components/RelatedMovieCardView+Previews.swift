//
//  RelatedMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Preview variant for `RelatedMovieCardView`.
///
/// Displays a single movie card to test layout, spacing and background behavior.
extension RelatedMovieCardView {

    static var preview: some View {
        PreviewID.reset()
        return RelatedMovieCardView(movie: SharedPreviewMovies.starWars)
            .padding()
            .background(Color(.systemBackground))
    }
}
