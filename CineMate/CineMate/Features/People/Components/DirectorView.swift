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
                .padding(.horizontal)

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
                        AsyncImage(url: director.profileURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                        Text(director.name)
                            .font(.subheadline)
                            .bold()

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No director information available.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
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
