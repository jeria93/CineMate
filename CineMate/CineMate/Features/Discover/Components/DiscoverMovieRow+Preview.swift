//
//  DiscoverMovieRow+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import SwiftUI

extension DiscoverMovieRow {
    /// Preconfigured preview variants for `DiscoverMovieRow`.
    /// Allows Xcode Previews to simulate different UI states, such as
    /// when a movie has a poster or when no poster is available.
    static var previewPoster: some View {
        DiscoverMovieRow(movie: DiscoverRowPreviewData.dune)
            .padding()
    }
    
    static var previewNoPoster: some View {
        DiscoverMovieRow(movie: DiscoverRowPreviewData.noPosterMovie)
            .padding()
    }
}
