//
//  PersonMetaInfoPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Preview data for `PersonMetaInfoView` showing different completeness levels.
enum PersonMetaInfoPreviewData {

    /// Full person detail (e.g. Mark Hamill) with all fields populated.
    static let full = PersonPreviewData.markHamill

    /// Completely empty person detail, used to test fallback UI.
    static let empty = PersonPreviewData.emptyDetail

    /// Partially filled detail with only gender set, rest is missing.
    static let partial = PersonDetail(
        id: PreviewID.next(),
        name: "Mystery Person",
        birthday: nil,
        deathday: nil,
        biography: nil,
        placeOfBirth: nil,
        profilePath: nil,
        imdbId: nil,
        gender: 2,
        knownForDepartment: nil,
        alsoKnownAs: []
    )
}
