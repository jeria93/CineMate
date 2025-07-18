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
        rent: nil,
        buy: nil
    )

}
