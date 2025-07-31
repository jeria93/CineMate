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
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: movie.posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
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
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(movie.title ?? "Untitled")
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .onTapGesture {
            if let stub = movie.asMovie {
                movieViewModel?.cacheStub(stub)
            }
            navigator.goToMovie(id: movie.id)
        }
        .frame(width: 100)
    }
}

#Preview("Default") {
    PersonMovieCardView.preview.withPreviewNavigation()
}

#Preview("Missing Poster") {
    PersonMovieCardView.previewMissingPoster.withPreviewNavigation()
}

#Preview("Missing Title") {
    PersonMovieCardView.previewMissingTitle.withPreviewNavigation()
}
