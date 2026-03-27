//
//  PersonMetaInfoView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-27.
//

import SwiftUI

struct PersonMetaInfoView: View {
    let detail: PersonDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let gender = detail.safeGenderText, !gender.isEmpty {
                Text("Gender: \(gender)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("Gender: Unknown")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }

            if let department = detail.knownForDepartment, !department.isEmpty {
                Text("Department: \(department)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("Department: Unknown")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }

            if detail.hasAliases {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Also known as:")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    ForEach(detail.alsoKnownAs, id: \.self) { alias in
                        Text(alias)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .padding(.top, 4)
            } else {
                Text("No known aliases")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Full Meta Info") {
    PersonMetaInfoView.previewFull
}

#Preview("Empty Meta Info") {
    PersonMetaInfoView.previewEmpty
}

#Preview("Partial Meta Info") {
    PersonMetaInfoView.previewPartial
}
