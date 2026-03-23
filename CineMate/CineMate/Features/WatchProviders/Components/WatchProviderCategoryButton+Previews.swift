//
//  WatchProviderCategoryButton+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

extension WatchProviderCategoryButton {
    
    static var previewSelected: some View {
        WatchProviderCategoryButton(
            category: .flatrate,
            isSelected: true,
            hasContent: true,
            onTap: {}
        )
        .padding()
    }
    
    static var previewUnselected: some View {
        WatchProviderCategoryButton(
            category: .rent,
            isSelected: false,
            hasContent: false,
            onTap: {}
        )
        .padding()
    }
    
    static var previewGroup: some View {
        VStack(spacing: 12) {
            previewSelected
            previewUnselected
        }
    }
    
    static var previewAllCategories: some View {
        HStack(spacing: 8) {
            ForEach(WatchProviderCategory.allCases) { category in
                WatchProviderCategoryButton(
                    category: category,
                    isSelected: category == .flatrate,
                    hasContent: category != .buy,
                    onTap: {}
                )
            }
        }
        .padding()
    }
}
