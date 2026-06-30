//
//  DiscoverMovieRow.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

struct DiscoverMovieRow: View {
    let movie: Movie

    var body: some View {
        MoviePosterView(
            movie: movie,
            configuration: .compact
        )
        .padding(.vertical, SharedUI.Spacing.small)
    }
}

#Preview("With Poster") {
    DiscoverMovieRow.previewPoster.withPreviewNavigation()
}

#Preview("No Poster") {
    DiscoverMovieRow.previewNoPoster.withPreviewNavigation()
}
