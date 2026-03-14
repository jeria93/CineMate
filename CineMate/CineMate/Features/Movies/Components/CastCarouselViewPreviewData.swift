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
    static let cast: [CastMember] = MovieCreditsPreviewData.starWarsCredits().cast
    
    /// A long cast list with unique IDs to avoid `ForEach` collisions in previews.
    /// Useful for testing scroll behavior and layout overflow.
    static let longCast: [CastMember] = {
        guard !cast.isEmpty else { return [] }
        return (1...30).map { index in
            let template = cast[(index - 1) % cast.count]
            return CastMember(
                id: PreviewID.scoped(.movieComponents, 100 + index),
                name: template.name,
                character: template.character,
                profilePath: template.profilePath
            )
        }
    }()
}
