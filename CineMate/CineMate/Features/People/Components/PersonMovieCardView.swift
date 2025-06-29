//
//  PersonMovieCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-26.
//

import SwiftUI

struct PersonMovieCardView: View {
    let movie: PersonMovieCredit

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: movie.posterURL) { phase in

                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(movie.title ?? "Untitled")
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

#Preview {
    PersonMovieCardView(movie: PreviewData.markHamillMovieCredits.first!)
}
