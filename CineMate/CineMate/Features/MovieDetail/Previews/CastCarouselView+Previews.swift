//
//  CastCarouselView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//

import SwiftUI

private struct CastCarouselPreviewWrapper: View {
    let cast: [CastMember]
    var body: some View {
        CastCarouselView(cast: cast)
            .previewStyle()
    }
}

#Preview("Long Names and Roles") {
    let longCast: [CastMember] = [
        CastMember(id: 1, name: "Maximilian Alexander von Habsburg", character: "Lord Commander", profilePath: nil),
        CastMember(id: 2, name: "A Very Very Long Actor Name", character: "Wanderer", profilePath: nil),
        CastMember(id: 3, name: "Short Name", character: "Short Role", profilePath: nil),
        CastMember(id: 4, name: "No Role Person", character: nil, profilePath: nil)
    ]

    return CastCarouselPreviewWrapper(cast: longCast)
}

#Preview("Star Wars Cast") {
    CastCarouselPreviewWrapper(cast: PreviewData.starWarsCredits.cast)
}

#Preview("Empty Cast") {
    CastCarouselPreviewWrapper(cast: [])
}
