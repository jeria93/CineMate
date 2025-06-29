//
//  KnownForScrollView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-28.
//

import SwiftUI

struct KnownForScrollView: View {
    let movies: [PersonMovieCredit]

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
                        ForEach(movies) { movie in
                            VStack(alignment: .leading) {
                                AsyncImage(url: movie.posterURL) { image in
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

                                Text(movie.title ?? "Unknown")
                                    .font(.caption)
                                    .frame(width: 100)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    KnownForScrollView(movies: PreviewData.markHamillMovieCredits)
}

#Preview("Fallback – Empty") {
    KnownForScrollView(movies: [])
}
