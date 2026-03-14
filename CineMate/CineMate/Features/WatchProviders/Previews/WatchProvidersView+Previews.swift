//
//  WatchProvidersView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-01.
//

import SwiftUI

extension WatchProvidersView {

    static var preview: some View {
        WatchProvidersView(
            movieId: 11,
            availability: PreviewData.mockWatchProviderAvailability,
            isLoading: false,
            errorMessage: nil
        )
        .padding()
    }

    static var previewFallbackRegion: some View {
        WatchProvidersView(
            movieId: 11,
            availability: PreviewData.mockWatchProviderFallbackAvailability,
            isLoading: false,
            errorMessage: nil
        )
        .padding()
    }

    static var previewEmpty: some View {
        WatchProvidersView(
            movieId: 11,
            availability: PreviewData.mockWatchProviderEmptyCatalogAvailability,
            isLoading: false,
            errorMessage: nil
        )
        .padding()
    }

    static var previewNoRegionData: some View {
        WatchProvidersView(
            movieId: 11,
            availability: PreviewData.mockWatchProviderUnavailableAvailability,
            isLoading: false,
            errorMessage: nil
        )
        .padding()
    }

    static var previewLoading: some View {
        WatchProvidersView(
            movieId: 11,
            availability: nil,
            isLoading: true,
            errorMessage: nil
        )
        .padding()
    }

    static var previewError: some View {
        WatchProvidersView(
            movieId: 11,
            availability: nil,
            isLoading: false,
            errorMessage: "Network unavailable"
        )
        .padding()
    }
}
