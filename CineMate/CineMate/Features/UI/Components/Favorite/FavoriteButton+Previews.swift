//
//  FavoriteButton+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension FavoriteButton {
    static var preview: some View {
        VStack(spacing: 20) {
            FavoriteButton(isFavorite: true) {}
            FavoriteButton(isFavorite: false) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
