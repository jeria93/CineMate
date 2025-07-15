//
//  GenreChipView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

extension GenreChipView {
    static var previewUnselected: some View {
        GenreChipView(
            genre: Genre(id: 28, name: "Action"),
            isSelected: false,
            onTap: {}
        )
        .padding()
        .background(Color(.systemBackground))
    }

    static var previewSelected: some View {
        GenreChipView(
            genre: Genre(id: 35, name: "Comedy"),
            isSelected: true,
            onTap: {}
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
