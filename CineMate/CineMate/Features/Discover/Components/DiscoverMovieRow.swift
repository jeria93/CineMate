//
//  DiscoverMovieRow.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-10.
//

import SwiftUI

struct DiscoverMovieRow: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: movie.posterSmallURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.2))
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))

        }
        .padding(.vertical, 8)
    }
}

#Preview("With Poster") {
    DiscoverMovieRow.previewPoster
}

#Preview("No Poster") {
    DiscoverMovieRow.previewNoPoster
}
