//
//  KnownForScrollView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-28.
//

import SwiftUI

struct KnownForScrollView: View {
    let movies: [PersonMovieCredit]
    @EnvironmentObject private var navigator: AppNavigator
    let movieViewModel: MovieViewModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().padding(.vertical, 8)

            Text("Most Iconic Roles")
                .font(.title3.bold())
                .padding(.horizontal)

            if movies.isEmpty {
                Text("No iconic roles found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movies) { credit in
                            VStack(alignment: .leading) {
                                AsyncImage(url: credit.posterURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                        .cornerRadius(12)
                                        .background(Color.yellow.opacity(0.1))
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 100, height: 150)
                                }

                                Text(credit.title ?? "Unknown")
                                    .font(.caption)
                                    .frame(width: 100)
                                    .lineLimit(1)
                            }
                            .onTapGesture {
                                if let stub = credit.asMovie {
                                    movieViewModel?.cacheStub(stub)
                                }
                                navigator.goToMovie(id: credit.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview("Known For – Full") {
    KnownForScrollView.previewFull.withPreviewNavigation()
}

#Preview("Known For – Empty") {
    KnownForScrollView.previewEmpty.withPreviewNavigation()
}

#Preview("Known For – Partial") {
    KnownForScrollView.previewPartial.withPreviewNavigation()
}

#Preview("Known For – Overflow") {
    KnownForScrollView.previewOverflow.withPreviewNavigation()
}

extension PersonMovieCredit {
    /// Converts a `PersonMovieCredit` into a simplified `Movie` model.
    /// Used to provide an immediate stub before full detail loads.
    var asMovie: Movie? {
        guard let title = title else { return nil }
        return Movie(
            id: id,
            title: title,
            overview: nil,
            posterPath: posterPath,
            backdropPath: nil,
            releaseDate: releaseDate,
            voteAverage: nil,
            genres: nil
        )
    }
}
