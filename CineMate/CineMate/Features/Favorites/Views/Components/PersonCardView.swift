//
//  PersonCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-13.
//

import SwiftUI

struct PersonCardView: View {
    let person: PersonRef

    var body: some View {
        VStack {
            PosterImageView(
                url: person.profileSmallURL,
                title: person.name,
                width: SharedUI.Size.posterCard.width,
                height: SharedUI.Size.posterCard.height,
                cornerRadius: SharedUI.Radius.small
            )

            Text(person.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

#Preview("test") {
    PersonCardView(
        person: .init(
            id: 1,
            name: "Test Person",
            profilePath: "/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg"
        )
    )
}
