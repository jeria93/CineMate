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
    let watchProviderRegion: WatchProviderRegion?
    let isLoading: Bool
}

@MainActor
extension PreviewFactory {
    static func movieDetailInfoContextWithDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: MovieDetailPreviewData.starWarsDetail,
            watchProviderRegion: PreviewData.mockWatchProviderRegion,
            isLoading: false
        )
    }

    static func movieDetailInfoContextWithEmptyDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: MovieDetailPreviewData.emptyDetail,
            watchProviderRegion: nil,
            isLoading: false
        )
    }

    static func movieDetailInfoContextLoading() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: nil,
            watchProviderRegion: nil,
            isLoading: true
        )
    }

    static func movieDetailInfoContextWithoutDetail() -> MovieDetailInfoPreviewContext {
        MovieDetailInfoPreviewContext(
            movie: SharedPreviewMovies.starWars,
            detail: nil,
            watchProviderRegion: nil,
            isLoading: false
        )
    }
}
