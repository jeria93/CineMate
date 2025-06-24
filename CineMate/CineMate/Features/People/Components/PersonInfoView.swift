//
//  PersonInfoView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct PersonInfoView: View {
    let detail: PersonDetail

    var body: some View {
        Group {
            if let birthday = detail.birthday {
                Text("Born: \(birthday)")
            }

            if let deathday = detail.deathday {
                Text("Died: \(deathday)")
            }

            if let place = detail.placeOfBirth {
                Text("Place of birth: \(place)")
            }

            if let bio = detail.biography, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview("Info – Mark Hamill") {
    PersonInfoView(detail: PreviewData.markHamillPersonDetail)
}
