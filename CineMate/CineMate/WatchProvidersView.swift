//
//  WatchProvidersView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

struct WatchProvidersView: View {
    let providers: [WatchProvider]

    var body: some View {

        if providers.isEmpty {
            Text("Not available for streaming in your region.")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Available on:")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(providers) { provider in
                            VStack(spacing: 4) {
                                if let logoURL = provider.logoURL {
                                    AsyncImage(url: logoURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
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
                }
            }
        }
    }
}

#Preview("With Mock Providers") {
    WatchProvidersView.preview
}

#Preview("No Providers") {
    WatchProvidersView.previewEmpty
}
