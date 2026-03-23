//
//  PersonMovieCardView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-26.
//

import SwiftUI

struct PersonMovieCardView: View {
  let movie: PersonMovieCredit
  @EnvironmentObject private var navigator: AppNavigator
  let movieViewModel: MovieViewModel?

  var body: some View {
    Button {
      if let stub = movie.asMovie {
        movieViewModel?.cacheStub(stub)
      }
      navigator.goToMovie(id: movie.id)
    } label: {
      VStack(alignment: .leading, spacing: 4) {
        posterImage
        .frame(width: 100, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 8))

        Text(movie.title ?? "Untitled")
          .font(.caption)
          .lineLimit(1)
          .foregroundStyle(.primary)
      }
      .frame(width: 100)
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var posterImage: some View {
    if ProcessInfo.processInfo.isPreview {
      fallbackPoster
    } else {
      AsyncImage(url: movie.posterURL) { phase in
        if let image = phase.image {
          image
            .resizable()
            .scaledToFill()
        } else {
          fallbackPoster
        }
      }
    }
  }

  private var fallbackPoster: some View {
    ZStack {
      Rectangle()
        .fill(Color.gray.opacity(0.2))
      Image(systemName: "film")
        .resizable()
        .scaledToFit()
        .frame(width: 30, height: 30)
        .foregroundStyle(.gray)
    }
  }
}

#Preview("Default") {
  PersonMovieCardView.preview
}

#Preview("Missing Poster") {
  PersonMovieCardView.previewMissingPoster
}

#Preview("Missing Title") {
  PersonMovieCardView.previewMissingTitle
}
