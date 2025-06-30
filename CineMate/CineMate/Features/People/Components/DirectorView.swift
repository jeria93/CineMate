//
//  DirectorView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

struct DirectorView: View {
    let director: CrewMember?
    let repository: MovieProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Director")
                .font(.headline)

            if let director {
                NavigationLink {
                    CastMemberDetailView(
                        member: CastMember(
                            id: director.id,
                            name: director.name,
                            character: "Director",
                            profilePath: director.profilePath
                        ),
                        viewModel: PersonViewModel(repository: repository)
                    )
                } label: {
                    HStack(spacing: 12) {
                        DirectorImageView(url: director.profileURL)

                        Text(director.name)
                            .font(.subheadline)
                            .bold()

                        Spacer()
                    }
                }
            } else {
                DirectorUnavailableView()
            }
        }
    }
}

#Preview("Director – Nolan") {
    DirectorView.previewWithDirector
}

#Preview("Director – No Director") {
    DirectorView.previewNoDirector
}
