//
//  RelatedMovieCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PosterImageView(
                url: movie.posterSmallURL,
                title: movie.title,
                width: 100,
                height: 150
            )

            Text(movie.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

#Preview {
    RelatedMovieCardView.preview
}
