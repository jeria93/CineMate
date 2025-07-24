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
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color.gray.opacity(0.15))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.indigo.opacity(0.8) : .clear, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 2 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onTap()
                }
            }
    }
}

#Preview("Unselected") {
    GenreChipView.previewUnselected
}

#Preview("Selected") {
    GenreChipView.previewSelected
}
// Piffa upp UI + implementera fallbacks?, återanvänd denna som standard senare?
