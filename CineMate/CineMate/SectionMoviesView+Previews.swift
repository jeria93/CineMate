//
//  SectionMoviesView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

extension SectionMoviesView {

    static var previewDefault: some View {
        SectionMoviesView(
            title: "Popular Movies",
            movies: SectionMoviesPreviewData.movies
        )
    }

    static var previewEmpty: some View {
        SectionMoviesView(
            title: "Empty Section",
            movies: []
        )
    }

    static var previewOneMovie: some View {
        SectionMoviesView(
            title: "Just One",
            movies: [SectionMoviesPreviewData.interstellar]
        )
    }
}
