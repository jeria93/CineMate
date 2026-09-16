//
//  PersonPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

/// Catalog-backed person details and movie credits for previews.
enum PersonPreviewData {

    static var markHamill: PersonDetail {
        DemoCatalog.personDetail(for: 2) ?? emptyDetail
    }

    static var movieCredits: [PersonMovieCredit] {
        DemoCatalog.movieCredits(for: 2) ?? []
    }

    static let emptyDetail = PersonDetail(
        id: PreviewID.scoped(.people, 999),
        name: "Unknown",
        birthday: nil,
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
