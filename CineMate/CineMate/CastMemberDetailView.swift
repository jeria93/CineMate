//
//  CastMemberDetailView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import SwiftUI

struct CastMemberDetailView: View {
    let member: CastMember

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: member.profileURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                    }

                }
                .frame(width: 180, height: 180)
                .clipShape(Circle())

                Text(member.name)
                    .font(.title)
                    .bold()

                if let role = member.character {
                    Text("Role: \(role)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(member.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

    #Preview("Cast Detail – Mark Hamill") {
        CastMemberDetailView.markHamillPreview
    }
