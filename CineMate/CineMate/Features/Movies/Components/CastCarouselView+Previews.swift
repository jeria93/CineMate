//
//  CastCarouselView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

extension CastCarouselView {

    /// Preview showing a realistic list of cast members (e.g. Star Wars).
    @MainActor
    static var preview: some View {
        CastCarouselView(
            cast: CastCarouselViewPreviewData.cast        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing a horizontally scrollable long cast list.
    /// Useful for testing scrolling behavior and UI wrapping.
    @MainActor
    static var longList: some View {
        CastCarouselView(
            cast: CastCarouselViewPreviewData.longCast        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing empty cast list (fallback UI state).
    @MainActor
    static var emptyCast: some View {
        CastCarouselView(
            cast: []
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
