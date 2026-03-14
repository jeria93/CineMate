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
    let resolvedRegionCode: String?
    let resolvedRegionName: String?

    private var regionLabel: String {
        if let resolvedRegionName, let resolvedRegionCode {
            return "\(resolvedRegionName) (\(resolvedRegionCode))"
        }
        if let resolvedRegionCode {
            return resolvedRegionCode
        }
        return "your region"
    }

    var body: some View {
        if providers.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(selection.emptyTitle)
                    .font(.subheadline.weight(.semibold))
                Text("Not available in \(regionLabel) right now.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(providers) { provider in
                        WatchProviderItemView(provider: provider)
                    }
                }
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
