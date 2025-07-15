//
//  GenreSelectorView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

struct GenreSelectorView: View {
    let genres: [Genre]
    let selectedGenreId: Int?
    let onSelect: (Genre) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(genres) { genre in
                    GenreChipView(
                        genre: genre,
                        isSelected: genre.id == selectedGenreId
                    ) {
                        onSelect(genre)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
    }
}

#Preview("Default") {
    GenreSelectorView.previewDefault
}
