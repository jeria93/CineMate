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
            Text("Gender: \(detail.genderText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let department = detail.knownForDepartment {
                Text("Department: \(department)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if detail.hasAliases {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Also known as:")
                        .font(.headline)

                    ForEach(detail.alsoKnownAs, id: \.self) { alias in
                        Text(alias)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PersonMetaInfoView(detail: PreviewData.markHamillPersonDetail)
}
