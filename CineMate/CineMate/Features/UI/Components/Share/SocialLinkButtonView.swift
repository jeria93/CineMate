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

    var body: some View {
        if let url {
            Link(destination: url) {
                Image(assetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.primary)
            }
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
