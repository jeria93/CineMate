//
//  WatchProvidersView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

extension WatchProvidersView {

    /// Preview with example providers (e.g. Netflix, Prime Video).
    /// Useful for UI testing and design purposes.
    static var preview: some View {
        WatchProvidersView(region: PreviewData.mockWatchProviderRegion)
            .padding()
    }

    /// Preview with no available providers (fallback state).
    /// Useful for testing the empty view scenario.
    static var previewEmpty: some View {
        WatchProvidersView(region: WatchProviderRegion(link: nil, flatrate: nil, rent: nil, buy: nil))
            .padding()
    }
}
