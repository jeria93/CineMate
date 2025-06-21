//
//  CastMemberView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-18.
//


import SwiftUI

extension CastMemberView {

    static var markHamillPreview: some View {
        NavigationStack {
            CastMemberView(member: PreviewData.starWarsCredits.cast[0])
        }
    }

    static var unknownActorPreview: some View {
        NavigationStack {
            CastMemberView(member: CastMember(
                id: 999,
                name: "Unknown Actor",
                character: nil,
                profilePath: nil
            ))
        }
    }

    static var longNamePreview: some View {
        NavigationStack {
            CastMemberView(member: PreviewData.longNameMember)
        }
    }
}
