//
//  DirectorPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Mock director variations for `DirectorView` previews.
enum DirectorPreviewData {
    static let nolan = CrewMember(
        id: PreviewID.next(),
        name: "Christopher Nolan",
        job: "Director",
        profilePath: "/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg"
    )

    static let partial = CrewMember(
        id: PreviewID.next(),
        name: "Unnamed Director",
        job: "Director",
        profilePath: nil
    )
}
