//
//  SocialLinkButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct SocialLinkButtonView: View {
    let url: URL?
    let assetName: String
    let accessibilityLabel: String

    init(url: URL?, assetName: String, accessibilityLabel: String? = nil) {
        self.url = url
        self.assetName = assetName
        self.accessibilityLabel = accessibilityLabel ?? assetName
    }

    var body: some View {
        if let url {
            Link(destination: url) {
                IconButtonLabel(accessibilityLabel: accessibilityLabel) {
                    Image(assetName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("SocialLinkButton – IMDb") {
    SocialLinkButtonView(
        url: URL(string: "https://www.imdb.com"),
        assetName: "imdb"
    )
    .padding()
}
