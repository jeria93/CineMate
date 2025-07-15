//
//  GenreChipView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//


import SwiftUI

struct GenreChipView: View {
    let genre: Genre
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(genre.name)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture {
                onTap()
            }
    }
}

#Preview("Unselected") {
    GenreChipView.previewUnselected
}

#Preview("Selected") {
    GenreChipView.previewSelected
}
// Piffa upp UI + implementera fallbacks?
