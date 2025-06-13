//
//  RelatedMoviesSection.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMoviesSection: View {
    let movies: [Movie]

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Related Movies")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movies) { movie in
                            RelatedMovieCardView(movie: movie)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    RelatedMoviesSection(movies: PreviewData.moviesList)
}
