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
    } else {
      Text("No external links available.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.vertical, 4)
    }
  }

  private var hasAnyLinks: Bool {
    imdbURL != nil || tmdbURL != nil || instagramURL != nil || twitterURL != nil
      || facebookURL != nil
  }
}

#Preview("Social Media Links") {
  PersonLinksView.preview
}
