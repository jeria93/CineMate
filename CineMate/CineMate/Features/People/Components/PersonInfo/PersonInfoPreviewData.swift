//
//  PersonInfoPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Preview data for `PersonInfoView` in various completion states.
enum PersonInfoPreviewData {

    /// Full detail for Mark Hamill with biography and birth date.
    static let markHamill = PersonPreviewData.markHamill

    /// Completely empty person, used to simulate missing API data.
    static let empty = PersonPreviewData.emptyDetail

    /// Partially filled detail with only name and birthday.
    static let partial = PersonDetail(
        id: PreviewID.next(),
        name: "Mystery Person",
        birthday: "1980-01-01",
        deathday: nil,
        biography: nil,
        placeOfBirth: nil,
        profilePath: nil,
        imdbId: nil,
        gender: nil,
        knownForDepartment: nil,
        alsoKnownAs: []
    )
}
