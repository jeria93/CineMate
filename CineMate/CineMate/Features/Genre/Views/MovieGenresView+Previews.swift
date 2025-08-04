//
//  MovieGenresView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-23.
//

import SwiftUI

extension MovieGenresView {
    /// Preview showing horizontal scroll of tappable genres.
    static var previewDefault: some View {
        MovieGenresView(genres: GenrePreviewData.genres)
            .withPreviewNavigation()
            .background(Color(.systemBackground))
    }

    /// Preview showing very long genre names and special characters.
    static var previewLongNames: some View {
        let customGenres: [Genre] = [
            Genre(id: PreviewID.next(), name: "Science Fiction & Fantasy Adventure"),
            Genre(id: PreviewID.next(), name: "🎬 Drama"),
            Genre(id: PreviewID.next(), name: "")
        ]

        return MovieGenresView(genres: customGenres)
            .withPreviewNavigation()
            .background(Color(.systemBackground))
    }
}
