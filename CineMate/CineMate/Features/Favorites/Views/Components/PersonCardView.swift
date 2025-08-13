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
                width: 100,
                height: 150
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

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
