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
                .foregroundStyle(Color.appTextSecondary)

            Text("Search for movies")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            Text("Try titles like *Star Wars* or *Inception*.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurface.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appTextSecondary.opacity(0.18), lineWidth: 1)
        )
        .padding()
    }
}

#Preview("SearchPromptView") {
    SearchPromptView()
}
