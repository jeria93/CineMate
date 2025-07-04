//
//  WatchProviderItemView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

struct WatchProviderItemView: View {
    let provider: WatchProvider

    var body: some View {
        VStack(spacing: 4) {
            if let logoURL = provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .transition(.scale)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "tv")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text(provider.providerName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview("Netflix") {
    WatchProviderItemView.previewNetflix
}

#Preview("Disney+") {
    WatchProviderItemView.previewDisneyPlus
}

#Preview("Missing Logo") {
    WatchProviderItemView.previewEmpty
}
