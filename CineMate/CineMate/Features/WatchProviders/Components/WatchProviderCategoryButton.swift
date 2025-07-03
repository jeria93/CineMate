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
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                onTap()
            }
        }) {
            Label {
                Text(category.rawValue)
                    .font(.caption)
            } icon: {
                Image(systemName: category.iconName)
                    .font(.caption)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(minWidth: 60)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.blue.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
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
