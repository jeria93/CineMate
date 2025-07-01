//
//  WatchProvidersView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

struct WatchProvidersView: View {
    let region: WatchProviderRegion
    @State private var selection: WatchProviderCategory = .flatrate

    enum WatchProviderCategory: String, CaseIterable, Identifiable {
        case flatrate = "Stream"
        case rent = "Rent"
        case buy = "Buy"

        var id: String { self.rawValue }
    }

    var selectedProviders: [WatchProvider] {
        switch selection {
        case .flatrate:
            return region.flatrate ?? []
        case .rent:
            return region.rent ?? []
        case .buy:
            return region.buy ?? []
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Select Option", selection: $selection) {
                ForEach(WatchProviderCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)

            if selectedProviders.isEmpty {
                Text("Not available for \(selection.rawValue.lowercased()) in your region.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedProviders) { provider in
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
