//
//  WatchProviderCategoryPicker.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

struct WatchProviderCategoryPicker: View {
    @Binding var selection: WatchProviderCategory

    var body: some View {
        HStack(spacing: 8) {
            ForEach(WatchProviderCategory.allCases) { category in
                WatchProviderCategoryButton(
                    category: category,
                    isSelected: category == selection,
                    onTap: {
                        selection = category
                    }
                )
            }
        }
        .padding(.top, 4)
    }
}

#Preview("Flatrate selected") {
    WatchProviderCategoryPicker(selection: .constant(.flatrate))
        .padding()
}
