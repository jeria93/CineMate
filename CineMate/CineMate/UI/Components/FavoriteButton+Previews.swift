//
//  FavoriteButton+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension FavoriteButton {
    static var preview: some View {
        Group {
            FavoriteButton(isFavorite: true, toggleAction: {})
            FavoriteButton(isFavorite: false, toggleAction: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(.systemGroupedBackground))
    }
}
