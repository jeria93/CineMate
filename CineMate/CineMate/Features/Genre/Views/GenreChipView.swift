//
//  GenreChipView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

/// A single genre chip with selection state and animation.
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
            .foregroundStyle(isSelected ? Color.tmdbNavy : Color.appTextPrimary)
            .background(
                isSelected
                ? AnyShapeStyle(LinearGradient(colors: [.tmdbBlue, .tmdbGreen],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                : AnyShapeStyle(Color.appSurface)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.tmdbNavy.opacity(0.35) : Color.appTextSecondary.opacity(0.20),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.tmdbNavy.opacity(isSelected ? 0.18 : 0.06),
                    radius: isSelected ? 3 : 1,
                    x: 0, y: isSelected ? 2 : 1)
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
