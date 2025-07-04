//
//  CastCarouselView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

extension CastCarouselView {
    /// Preview showing a typical list of cast members (e.g. from Star Wars).
    @MainActor
    static var preview: some View {
        CastCarouselView(
            cast: PreviewData.starWarsCredits.cast,
            repository: PreviewFactory.repository
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing horizontal scroll with a long cast list (30 members).
    /// Useful for testing scrolling behavior and layout wrapping.
    @MainActor
    static var longList: some View {
        let longCast = Array(
            repeating: PreviewData.starWarsCredits.cast,
            count: 10
        ).flatMap { $0 }.prefix(30)

        return CastCarouselView(
            cast: Array(longCast),
            repository: PreviewFactory.repository
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview showing fallback state when no cast information is available.
    /// Ensures the UI provides feedback instead of rendering empty.
    @MainActor
    static var emptyCast: some View {
        CastCarouselView(
            cast: [],
            repository: PreviewFactory.repository
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
