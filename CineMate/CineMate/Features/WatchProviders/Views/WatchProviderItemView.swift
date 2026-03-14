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
        VStack(spacing: 6) {
            logoView
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(provider.displayName)
                .font(.caption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 72)
        }
        .frame(width: 76)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var logoView: some View {
        if let logoURL = provider.logoURL {
            AsyncImage(url: logoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                case .failure:
                    fallbackLogo
                @unknown default:
                    fallbackLogo
                }
            }
        } else {
            fallbackLogo
        }
    }

    private var fallbackLogo: some View {
        Image(systemName: "tv")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
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
