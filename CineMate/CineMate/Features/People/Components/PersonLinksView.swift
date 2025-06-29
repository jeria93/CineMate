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
        HStack(spacing: 20) {
            SocialLinkButtonView(url: imdbURL, assetName: "imdb")
            SocialLinkButtonView(url: tmdbURL, assetName: "themoviedatabase")
            SocialLinkButtonView(url: instagramURL, assetName: "instagram")
            SocialLinkButtonView(url: twitterURL, assetName: "x")
            SocialLinkButtonView(url: facebookURL, assetName: "facebook")
            ShareLinkButtonView(url: tmdbURL)
            Spacer()
        }
        .padding(.vertical)
    }
}

#Preview("Social Media Links") {
    PersonLinksView.preview
}
