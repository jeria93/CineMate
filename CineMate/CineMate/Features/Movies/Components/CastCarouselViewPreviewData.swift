//
//  CastCarouselViewPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Mock data specifically for `CastCarouselView` previews.
///
/// This file extracts commonly used cast lists (e.g. from Star Wars)
/// and generates longer lists for scroll testing.
enum CastCarouselViewPreviewData {

    /// A small, realistic list of cast members from the Star Wars universe.
    /// Used to simulate a normal cast carousel.
    static let cast: [CastMember] = PreviewData.starWarsCredits().cast
    /// A long cast list with up to 30 entries, created by repeating `cast`.
    /// Useful for testing scroll behavior and layout overflow.
    static let longCast: [CastMember] = Array(
        repeating: cast,
        count: 10
    )
    .flatMap { $0 }
    .prefix(30)
    .map { $0 }
}
