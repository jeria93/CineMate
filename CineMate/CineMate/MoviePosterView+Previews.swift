//
//  MoviePosterView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

extension MoviePosterView {
    
    static var previewDefault: some View {
        MoviePosterView(movie: MoviePosterPreviewData.dune)
    }
    
    static var previewMissingPoster: some View {
        MoviePosterView(movie: MoviePosterPreviewData.duneNoPoster)
    }
}
