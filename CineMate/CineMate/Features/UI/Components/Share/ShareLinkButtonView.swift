//
//  ShareLinkButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct IconButtonLabel<Content: View>: View {
    let accessibilityLabel: String
    @ViewBuilder var content: () -> Content

    init(
        accessibilityLabel: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.content = content
    }

    var body: some View {
        content()
            .frame(width: SharedUI.Size.iconButton, height: SharedUI.Size.iconButton)
            .contentShape(Rectangle())
            .accessibilityLabel(accessibilityLabel)
    }
}

struct ShareLinkButtonView: View {
    let url: URL?

    var body: some View {
        if let url {
            ShareLink(item: url) {
                IconButtonLabel(accessibilityLabel: "Share link") {
                    Image(systemName: "square.and.arrow.up.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("ShareLinkButton – TMDB") {
    ShareLinkButtonView(
        url: URL(string: "https://www.themoviedb.org/person/1")
    )
    .padding()
}
