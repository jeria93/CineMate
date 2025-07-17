//
//  PersonInfoPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

enum PersonInfoPreviewData {
    static let markHamill = PreviewData.markHamillPersonDetail
    static let empty = PreviewData.emptyPersonDetail

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
