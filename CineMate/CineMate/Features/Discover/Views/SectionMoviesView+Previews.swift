//
//  SectionMoviesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

extension SectionMoviesView {
    static var previewDefault: some View {
        SectionMoviesView(movies: SectionMoviesPreviewData.movies)
    }

    static var previewSingle: some View {
        SectionMoviesView(movies: [SharedPreviewMovies.dune])
    }
}
