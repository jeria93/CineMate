//
//  MovieDetailActionBarView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Preview variant for `MovieDetailActionBarView`.
///
/// Used to test layout and appearance with a sample movie.
extension MovieDetailActionBarView {

    static var previewDefault: some View {
        PreviewID.reset()
        return MovieDetailActionBarView(
            movie: SharedPreviewMovies.starWars,
            videos: PreviewData.sampleVideos
        )
            .padding()
            .background(Color(.systemBackground))
    }
}
