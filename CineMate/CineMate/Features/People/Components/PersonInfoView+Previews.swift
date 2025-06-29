//
//  PersonInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

extension PersonInfoView {

    static var previewMarkHamill: some View {
        PersonInfoView(detail: PreviewData.markHamillPersonDetail)
            .padding()
    }

    static var previewEmpty: some View {
        PersonInfoView(detail: PreviewData.emptyPersonDetail)
            .padding()
    }

    static var previewPartial: some View {
        PersonInfoView(detail: .init(
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
        ))
        .padding()
    }
}
