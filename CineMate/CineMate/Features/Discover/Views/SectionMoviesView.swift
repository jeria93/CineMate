//
//  SectionMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-13.
//

import SwiftUI

struct SectionMoviesView: View {
    let movies: [Movie]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(movies) { movie in
                    DiscoverMovieRow(movie: movie)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Default") {
    SectionMoviesView.previewDefault.withPreviewNavigation()
}

#Preview("Single") {
    SectionMoviesView.previewSingle.withPreviewNavigation()
}
