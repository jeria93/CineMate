//
//  MovieGenresView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import SwiftUI

struct MovieGenresView: View {
    let genres: [String]

    var body: some View {
        if genres.isEmpty {
            Label("Genres not available", systemImage: "questionmark.app.dashed")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(genres, id: \.self) { genre in
                        NavigationLink(destination: GenreDetailView(genreName: genre)) {
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}

#Preview("With Genres") {
    MovieGenresView.previewGenres
}

#Preview("Empty Genres") {
    MovieGenresView.previewEmpty
}

extension MovieGenresView {
    /// Shows a list of genre chips with links
    static var previewGenres: some View {
        MovieGenresView(genres: Genre.all.map { $0.name })
            .padding()
            .background(Color(.systemBackground))
    }

    /// Shows fallback UI when no genres are available
    static var previewEmpty: some View {
        MovieGenresView(genres: [])
            .padding()
            .background(Color(.systemBackground))
    }
}
