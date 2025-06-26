//
//  HorizontalMoviesScrollView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import SwiftUI

struct HorizontalMoviesScrollView: View {
    let movies: [PersonMovieCredit]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(movies, id: \.uniqueKey) { movie in
                    VStack(alignment: .leading) {
                        AsyncImage(url: movie.posterURL) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFit()
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: 100, height: 150)
                        .cornerRadius(8)

                        Text(movie.title ?? "Untitled")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(width: 100)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HorizontalMoviesScrollView(movies: PreviewData.markHamillMovieCredits)
        .padding()
}

//Navigation to movies? + button(show more if there is more)
