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

            if let link = region.link, let url = URL(string: link) {
                Divider()
                Link(destination: url) {
                    HStack {
                        Text("See all streaming options")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
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
