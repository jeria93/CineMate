//
//  CastMemberView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-17.
//

import SwiftUI

struct CastMemberView: View {
    let member: CastMember

    var body: some View {
        NavigationLink {
            CastMemberDetailView(
                member: member,
                viewModel: PersonViewModel(repository: MockMovieRepository())
                )
        } label: {
            VStack(alignment: .center, spacing: 4) {
                AsyncImage(url: member.profileURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())

                Text(member.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(height: 34)

                Text(member.character?.isEmpty == false ? member.character! : "Unknown")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(height: 28)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)

    }
}

#Preview("Mark Hamill") {
    CastMemberView.markHamillPreview
}

#Preview("Unknown Actor") {
    CastMemberView.unknownActorPreview
}

#Preview("Long Name") {
    CastMemberView.longNamePreview
}
