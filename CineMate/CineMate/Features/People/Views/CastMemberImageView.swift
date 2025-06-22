//
//  CastMemberImageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct CastMemberImageView: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
            }

        }
        .frame(width: 180, height: 180)
        .clipShape(Circle())
    }
}

#Preview("Image – Mark Hamill") {
    CastMemberImageView(url: PreviewData.starWarsCredits.cast.first?.profileURL)
}
