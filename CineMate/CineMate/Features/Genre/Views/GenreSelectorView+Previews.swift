//
//  GenreSelectorView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

extension GenreSelectorView {
    static var previewDefault: some View {
        GenreSelectorView(
            genres: GenrePreviewData.genres,
            selectedGenreId: 35
        ) { _ in }
        .background(Color(.systemBackground))
    }
}
