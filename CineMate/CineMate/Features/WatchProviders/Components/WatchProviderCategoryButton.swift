//
//  WatchProviderCategoryButton.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

struct WatchProviderCategoryButton: View {
    let category: WatchProviderCategory
    let isSelected: Bool
    let hasContent: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.caption)

                Text(category.title)
                    .font(.caption)

                Circle()
                    .fill(hasContent ? Color.green : Color.gray)
                    .frame(width: 6, height: 6)
                    .opacity(isSelected ? 0.9 : 0.7)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(minWidth: 72)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.accentColor.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
            }
            .opacity(isSelected || hasContent ? 1 : 0.8)
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Selected") {
    WatchProviderCategoryButton.previewSelected
}

#Preview("Unselected") {
    WatchProviderCategoryButton.previewUnselected
}

#Preview("Group") {
    WatchProviderCategoryButton.previewGroup
}

#Preview("All Categories Row") {
    WatchProviderCategoryButton.previewAllCategories
}
