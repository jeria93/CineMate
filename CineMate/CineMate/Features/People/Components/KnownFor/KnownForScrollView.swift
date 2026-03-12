//
//  KnownForScrollView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-28.
//

import SwiftUI

struct KnownForScrollView: View {
  let movies: [PersonMovieCredit]
  let movieViewModel: MovieViewModel?

  var body: some View {
    if movies.isEmpty {
      Text("No known-for titles available.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    } else {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(movies, id: \.uniqueKey) { credit in
            PersonMovieCardView(movie: credit, movieViewModel: movieViewModel)
          }
        }
        .padding(.horizontal)
      }
    }
  }
}

#Preview("Known For – Full") {
  KnownForScrollView.previewFull
}

#Preview("Known For – Empty") {
  KnownForScrollView.previewEmpty
}

#Preview("Known For – Partial") {
  KnownForScrollView.previewPartial
}

#Preview("Known For – Overflow") {
  KnownForScrollView.previewOverflow
}
