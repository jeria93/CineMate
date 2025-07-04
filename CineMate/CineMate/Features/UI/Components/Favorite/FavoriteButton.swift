//
//  FavoriteButton.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct FavoriteButton: View {
    let isFavorite: Bool
    let toggleAction: () -> Void
    
    var body: some View {
        Button(action: toggleAction) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? .red : .gray)
                .font(.title2)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FavoriteButton.preview
}
