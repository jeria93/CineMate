//
//  CastCarouselView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

extension CastCarouselView {
    static var preview: some View {
        CastCarouselView(
            cast: PreviewData.starWarsCredits.cast,
            repository: PreviewFactory.repository
        )
        .padding()
        .background(Color(.systemBackground))
    }

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
}
