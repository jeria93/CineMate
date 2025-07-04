//
//  PersonMetaInfoView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

extension PersonMetaInfoView {
    /// A preview with full person detail data (e.g. Mark Hamill).
    static var previewFull: some View {
        PersonMetaInfoView(detail: PreviewData.markHamillPersonDetail)
            .padding()
            .background(Color(.systemBackground))
    }

    /// A preview with empty detail to test fallback UI (e.g. unknown person).
    static var previewEmpty: some View {
        PersonMetaInfoView(detail: PreviewData.emptyPersonDetail)
            .padding()
            .background(Color(.systemBackground))
    }

    /// A preview with partial data (e.g. gender only) to simulate edge cases.
    static var previewPartial: some View {
        PersonMetaInfoView(detail: .init(
            id: 123,
            name: "Mystery Person",
            birthday: nil,
            deathday: nil,
            biography: nil,
            placeOfBirth: nil,
            profilePath: nil,
            imdbId: nil,
            gender: 1,
            knownForDepartment: nil,
            alsoKnownAs: []
        ))
        .padding()
        .background(Color(.systemBackground))
    }
}
