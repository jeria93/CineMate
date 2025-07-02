//
//  WatchProviderItemView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-02.
//

import SwiftUI

extension WatchProviderItemView {
    
    static var previewNetflix: some View {
        WatchProviderItemView(provider: PreviewData.mockWatchProviders[0])
            .padding()
    }
    
    static var previewDisneyPlus: some View {
        WatchProviderItemView(provider: PreviewData.mockWatchProviders[2])
            .padding()
    }

    static var previewEmpty: some View {
        WatchProviderItemView(provider: WatchProvider(
            providerId: 999,
            providerName: "Unknown",
            logoPath: nil
        ))
        .padding()
    }
}
