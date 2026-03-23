//
//  MovieDetailInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

@MainActor
extension MovieDetailInfoView {
    /// Preview with full detail data.
    static var previewWithDetail: some View {
        let context = PreviewFactory.movieDetailInfoContextWithDetail()
        return MovieDetailInfoView(
            movie: context.movie,
            detail: context.detail,
            watchProviderAvailability: context.watchProviderAvailability,
            isWatchProvidersLoading: context.isWatchProvidersLoading,
            watchProviderErrorMessage: context.watchProviderErrorMessage,
            isLoading: context.isLoading
        )
        .padding()
    }

    /// Preview with empty detail data.
    static var previewWithEmptyDetail: some View {
        let context = PreviewFactory.movieDetailInfoContextWithEmptyDetail()
        return MovieDetailInfoView(
            movie: context.movie,
            detail: context.detail,
            watchProviderAvailability: context.watchProviderAvailability,
            isWatchProvidersLoading: context.isWatchProvidersLoading,
            watchProviderErrorMessage: context.watchProviderErrorMessage,
            isLoading: context.isLoading
        )
        .padding()
    }

    /// Preview when loading details.
    static var previewLoading: some View {
        let context = PreviewFactory.movieDetailInfoContextLoading()
        return MovieDetailInfoView(
            movie: context.movie,
            detail: context.detail,
            watchProviderAvailability: context.watchProviderAvailability,
            isWatchProvidersLoading: context.isWatchProvidersLoading,
            watchProviderErrorMessage: context.watchProviderErrorMessage,
            isLoading: context.isLoading
        )
        .padding()
    }

    /// Preview with no detail data available.
    static var previewNoDetail: some View {
        let context = PreviewFactory.movieDetailInfoContextWithoutDetail()
        return MovieDetailInfoView(
            movie: context.movie,
            detail: context.detail,
            watchProviderAvailability: context.watchProviderAvailability,
            isWatchProvidersLoading: context.isWatchProvidersLoading,
            watchProviderErrorMessage: context.watchProviderErrorMessage,
            isLoading: context.isLoading
        )
        .padding()
    }
}
