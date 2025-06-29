//
//  ShareLinkButtonView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct ShareLinkButtonView: View {
    let url: URL?
    
    var body: some View {
        if let url {
            ShareLink(item: url) {
                Image(systemName: "square.and.arrow.up.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview("ShareLinkButton – TMDB") {
    ShareLinkButtonView(
        url: URL(string: "https://www.themoviedb.org/person/1")
    )
    .padding()
}
