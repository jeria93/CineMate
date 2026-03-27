//
//  PersonLinksView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct PersonLinksView: View {
    let imdbURL: URL?
    let tmdbURL: URL?
    let instagramURL: URL?
    let twitterURL: URL?
    let facebookURL: URL?

    var body: some View {
        if hasAnyLinks {
            HStack(spacing: SharedUI.Spacing.xLarge) {
                ForEach(socialButtons) { button in
                    SocialLinkButtonView(
                        url: button.url,
                        assetName: button.assetName,
                        accessibilityLabel: button.accessibilityLabel
                    )
                }
                ShareLinkButtonView(url: tmdbURL)
                Spacer()
            }
            .padding(.vertical)
        } else {
            Text("No external links available.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.vertical, SharedUI.Spacing.xSmall)
        }
    }

    private var socialButtons: [SocialButtonItem] {
        [
            .init(id: "imdb", assetName: "imdb", accessibilityLabel: "Open IMDb", url: imdbURL),
            .init(
                id: "tmdb",
                assetName: "themoviedatabase",
                accessibilityLabel: "Open The Movie Database",
                url: tmdbURL
            ),
            .init(id: "instagram", assetName: "instagram", accessibilityLabel: "Open Instagram", url: instagramURL),
            .init(id: "x", assetName: "x", accessibilityLabel: "Open X", url: twitterURL),
            .init(id: "facebook", assetName: "facebook", accessibilityLabel: "Open Facebook", url: facebookURL)
        ]
    }

    private var hasAnyLinks: Bool {
        socialButtons.contains { $0.url != nil } || tmdbURL != nil
    }
}

#Preview("Social Media Links") {
    PersonLinksView.preview
}

private struct SocialButtonItem: Identifiable {
    let id: String
    let assetName: String
    let accessibilityLabel: String
    let url: URL?
}
