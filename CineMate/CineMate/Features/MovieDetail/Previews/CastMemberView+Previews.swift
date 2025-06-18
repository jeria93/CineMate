//
//  CastMemberView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//


import SwiftUI

#Preview("CastMember – Mark Hamill") {
    CastMemberView(member: PreviewData.starWarsCredits.cast[0])
        .previewStyle()
}

#Preview("CastMember – Carrie Fisher") {
    CastMemberView(member: PreviewData.starWarsCredits.cast[2])
        .previewStyle()
}

#Preview("CastMember – Unknown Role") {
    CastMemberView(member: CastMember(
        id: 999,
        name: "Mystery Actor",
        character: nil,
        profilePath: nil
    ))
    .previewStyle()
}

#Preview("CastMember – Long Name + Role") {
    CastMemberView(member: PreviewData.longNameMember)
        .previewStyle()
}
