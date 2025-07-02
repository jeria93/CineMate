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

    var selectedProviders: [WatchProvider] {
        switch selection {
        case .flatrate: return region.flatrate ?? []
        case .rent:     return region.rent ?? []
        case .buy:      return region.buy ?? []
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WatchProviderCategoryPicker(selection: $selection)
            WatchProviderListView(providers: selectedProviders, selection: selection)
        }
        .padding(.vertical, 8)
    }
}

#Preview("With Mock Providers") {
    WatchProvidersView.preview
}

#Preview("No Providers") {
    WatchProvidersView.previewEmpty
}
// Create preview data for rent?
// Can you actually open an app?
