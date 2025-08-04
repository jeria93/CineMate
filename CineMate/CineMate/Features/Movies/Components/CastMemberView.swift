//
//  CastMemberView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-17.
//

import SwiftUI

struct CastMemberView: View {
    let member: CastMember
    @EnvironmentObject private var nav: AppNavigator

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            AsyncImage(url: member.profileURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(member.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 34)

            Text(member.displayCharacter)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)
        }
        .frame(width: 80)
        .contentShape(Rectangle())
        .onTapGesture { nav.goToPerson(id: member.id) }
    }
}

private extension CastMember {
    /// Fallback-safe representation of the character string.
    var displayCharacter: String {
        if let character, !character.isEmpty {
            return character
        } else {
            return "Unknown"
        }
    }
}

#Preview("Mark Hamill") {
    CastMemberView.markHamill
}

#Preview("Unknown Actor") {
    CastMemberView.unknownActor
}

#Preview("Long Name") {
    CastMemberView.longName
}
