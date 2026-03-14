//
//  PreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

/// Provides static mock data for SwiftUI previews.
struct PreviewData {

    static let sampleVideos: [MovieVideo] = [
        MovieVideo(
            id: "12345",
            key: "dQw4w9WgXcQ",
            name: "Official Trailer",
            site: "YouTube",
            type: "Trailer"
        )
    ]

    static let mockWatchProviders: [WatchProvider] = [
        WatchProvider(providerId: 8, providerName: "Netflix", logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg"),
        WatchProvider(providerId: 9, providerName: "Amazon Prime Video", logoPath: "/emthp39XA2YScoYL1p0sdbAH2WA.jpg"),
        WatchProvider(providerId: 337, providerName: "Disney+", logoPath: "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg")
    ]

    static let mockWatchProviderRegion = WatchProviderRegion(
        link: "https://www.themoviedb.org/movie/11/watch",
        flatrate: mockWatchProviders,
        rent: [mockWatchProviders[1]],
        buy: nil,
        free: nil,
        ads: nil
    )

    static let mockWatchProviderRegionRentOnly = WatchProviderRegion(
        link: "https://www.themoviedb.org/movie/11/watch?locale=US",
        flatrate: nil,
        rent: [mockWatchProviders[1], mockWatchProviders[2]],
        buy: nil,
        free: nil,
        ads: nil
    )

    static let mockWatchProviderRegionEmptyCatalog = WatchProviderRegion(
        link: "https://www.themoviedb.org/movie/11/watch?locale=SE",
        flatrate: nil,
        rent: nil,
        buy: nil,
        free: nil,
        ads: nil
    )

    static let mockWatchProviderAvailability = WatchProviderAvailability(
        requestedRegionCode: "SE",
        fallbackRegionCode: "US",
        resolvedRegionCode: "SE",
        source: .requestedRegion,
        region: mockWatchProviderRegion
    )

    static let mockWatchProviderFallbackAvailability = WatchProviderAvailability(
        requestedRegionCode: "SE",
        fallbackRegionCode: "US",
        resolvedRegionCode: "US",
        source: .fallbackRegion,
        region: mockWatchProviderRegionRentOnly
    )

    static let mockWatchProviderUnavailableAvailability = WatchProviderAvailability.unavailable(
        requestedRegionCode: "SE",
        fallbackRegionCode: "US"
    )

    static let mockWatchProviderEmptyCatalogAvailability = WatchProviderAvailability(
        requestedRegionCode: "SE",
        fallbackRegionCode: "US",
        resolvedRegionCode: "SE",
        source: .requestedRegion,
        region: mockWatchProviderRegionEmptyCatalog
    )

}
