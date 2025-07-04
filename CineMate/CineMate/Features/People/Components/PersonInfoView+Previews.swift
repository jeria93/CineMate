//
//  PersonInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

extension PersonInfoView {

    /// Preview with full data (e.g. Mark Hamill)
    static var previewMarkHamill: some View {
        PersonInfoView(detail: PreviewData.markHamillPersonDetail)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview with no data available (empty state)
    static var previewEmpty: some View {
        PersonInfoView(detail: PreviewData.emptyPersonDetail)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Preview with partial data (e.g. birthday but no bio)
    static var previewPartial: some View {
        let partialDetail = PersonDetail(
            id: 999,
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

        return PersonInfoView(detail: partialDetail)
            .padding()
            .background(Color(.systemBackground))
    }
}
