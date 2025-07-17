//
//  CastMemberPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Mock cast member data for `CastMemberView` previews.
/// Keeps data isolated for clarity and reuse.
enum CastMemberPreviewData {

    static let markHamill = CastMember(
        id: PreviewID.next(),
        name: "Mark Hamill",
        character: "Luke Skywalker",
        profilePath: "/2ZulC2Ccq1yv3pemusks6Zlfy2s.jpg"
    )

    static let unknownActor = CastMember(
        id: PreviewID.next(),
        name: "Unknown Actor",
        character: nil,
        profilePath: nil
    )

    static let longNameActor = CastMember(
        id: PreviewID.next(),
        name: "This is a really really really long actor name",
        character: "Extraordinary Sidekick of Episode 47 Part 3",
        profilePath: nil
    )
}
