//
//  EmptyStateView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.gray)

            Text(title)
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let actionTitle, let onAction {
                Button(actionTitle, action: onAction)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
    }
}

#Preview("No Results") {
    EmptyStateView.previewNoResults
}

#Preview("No Favorites") {
    EmptyStateView.previewNoFavorites
}

#Preview("Generic") {
    EmptyStateView.previewGeneric
}

extension EmptyStateView {
    static var previewNoResults: some View {
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or filter options."
        )
    }

    static var previewNoFavorites: some View {
        EmptyStateView(
            systemImage: "heart.slash",
            title: "No Favorites Yet",
            message: "Tap the heart icon to save movies you love.",
            actionTitle: "Browse Movies",
            onAction: { print("Browse tapped") }
        )
    }

    static var previewGeneric: some View {
        EmptyStateView(
            systemImage: "film",
            title: "Nothing to Show",
            message: "There’s no content here at the moment."
        )
    }
}
