//
//  PersonMetaInfoPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Mock person detail variations for `PersonMetaInfoView` previews.
enum PersonMetaInfoPreviewData {

    /// Full person detail (e.g. Mark Hamill).
    static let full = PreviewData.markHamillPersonDetail

    /// Empty/unknown person with no gender, department, or aliases.
    static let empty = PreviewData.emptyPersonDetail

    /// Only gender populated; other fields empty.
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
