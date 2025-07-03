//
//  WatchProviderListView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

struct WatchProviderListView: View {
    let providers: [WatchProvider]
    let selection: WatchProviderCategory

    var body: some View {

        if providers.isEmpty {

            Text("Not available for \(selection.rawValue.lowercased()) in your region.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .transition(.opacity)
                .animation(.easeInOut, value: providers)

        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(providers) { provider in
                        WatchProviderItemView(provider: provider)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .animation(.easeInOut, value: providers)
            }
        }
    }
}

#Preview("With Providers") {
    WatchProviderListView.previewWithData
}

#Preview("No Providers") {
    WatchProviderListView.previewEmpty
}
