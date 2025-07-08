//
//  SearchPromptView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-08.
//

import SwiftUI

/// A friendly prompt shown when the search query is empty.
struct SearchPromptView: View {

    var body: some View {
        
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("Search for movies")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Try titles like *Star Wars* or *Inception*.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .padding()
    }
}

#Preview("SearchPromptView") {
    SearchPromptView()
}
