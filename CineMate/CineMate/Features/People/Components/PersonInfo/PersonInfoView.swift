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
        VStack(alignment: .leading, spacing: 8) {
            if let birthday = detail.birthday {
                Text("Born: \(birthday)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

                if let deathday = detail.deathday {
                    Text("Died: \(deathday)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)

                    if let livedYears = DateHelper.calculateYearsLived(
                        birthday: birthday,
                        deathday: deathday
                    ) {
                        Text("Lived \(livedYears) years")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                } else if let age = DateHelper.calculateAge(from: birthday) {
                    Text("Age: \(age)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            } else {
                Text("Birthday: Unknown")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }

            if let place = detail.placeOfBirth {
                Text("Place of birth: \(place)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("Place of birth: Unknown")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }

            if let bio = detail.biography, !bio.isEmpty {
                BiographyView(text: bio)
            } else {
                Text("Biography not available.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Info – Mark Hamill") {
    PersonInfoView.previewMarkHamill
}

#Preview("Info – Empty") {
    PersonInfoView.previewEmpty
}

#Preview("Info – Partial") {
    PersonInfoView.previewPartial
}
