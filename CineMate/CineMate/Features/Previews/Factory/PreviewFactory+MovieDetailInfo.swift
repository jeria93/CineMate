//
//  PreviewFactory+MovieDetailInfo.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-23.
//

import Foundation

struct MovieDetailInfoPreviewContext {
    let movie: Movie
    let detail: MovieDetail?
    let watchProviderAvailability: WatchProviderAvailability?
    let isWatchProvidersLoading: Bool
    let watchProviderErrorMessage: String?
    let isLoading: Bool
}

@MainActor
extension PreviewFactory {
    static func movieDetailInfoContextWithDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: MovieDetailPreviewData.starWarsDetail,
            watchProviderAvailability: PreviewData.mockWatchProviderAvailability,
            isWatchProvidersLoading: false,
            watchProviderErrorMessage: nil,
            isLoading: false
        )
    }

    static func movieDetailInfoContextWithEmptyDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: MovieDetailPreviewData.emptyDetail,
            watchProviderAvailability: nil,
            isWatchProvidersLoading: false,
            watchProviderErrorMessage: nil,
            isLoading: false
        )
    }

    static func movieDetailInfoContextLoading() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: nil,
            watchProviderAvailability: nil,
            isWatchProvidersLoading: true,
            watchProviderErrorMessage: nil,
            isLoading: true
        )
    }

    static func movieDetailInfoContextWithoutDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: nil,
            watchProviderAvailability: nil,
            isWatchProvidersLoading: false,
            watchProviderErrorMessage: "Could not load watch providers.",
            isLoading: false
        )
    }
}
