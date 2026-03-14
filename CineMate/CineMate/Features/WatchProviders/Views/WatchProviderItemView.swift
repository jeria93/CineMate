//
//  WatchProviderItemView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

struct WatchProviderItemView: View {
    let provider: WatchProvider

    private enum Layout {
        static let cardWidth: CGFloat = 78
        static let cardHeight: CGFloat = 90
        static let logoSize: CGFloat = 56
        static let nameHeight: CGFloat = 14
    }

    var body: some View {
        VStack(spacing: 8) {
            logoView
                .frame(width: Layout.logoSize, height: Layout.logoSize)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(provider.displayName)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
                .allowsTightening(true)
                .multilineTextAlignment(.center)
                .frame(width: Layout.cardWidth - 6, height: Layout.nameHeight, alignment: .top)
        }
        .frame(width: Layout.cardWidth, height: Layout.cardHeight, alignment: .top)
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

#Preview("Long Name") {
    WatchProviderItemView.previewLongName
}

#Preview("Missing Logo") {
    WatchProviderItemView.previewEmpty
}
