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
            width: SharedUI.Size.posterCompact.width,
            height: SharedUI.Size.posterCompact.height,
            cornerRadius: SharedUI.Radius.medium,
            shadowRadius: 4
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
