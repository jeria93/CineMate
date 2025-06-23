//
//  CastCarouselView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

import SwiftUI

extension CastCarouselView {
    static var preview: some View {
        CastCarouselView(
            cast: PreviewData.starWarsCredits.cast,
            repository: MockMovieRepository()
        )
    }

    static var longListPreview: some View {
        let longCast = Array(repeating: PreviewData.starWarsCredits.cast, count: 10).joined().prefix(30)
        return CastCarouselView(
            cast: Array(longCast),
            repository: MockMovieRepository()
        )
    }
}
