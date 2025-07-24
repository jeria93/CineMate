//
//  MovieGenresView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import SwiftUI

struct MovieGenresView: View {
    let genres: [Genre]
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        if genres.isEmpty {
            Label("Genres not available", systemImage: "questionmark.app.dashed")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(genres) { genre in
                        Text(genre.name)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                            )
                            .contentShape(Capsule())
                            .onTapGesture {
                                navigator.goToGenre(genre.name)
                            }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

#Preview("With Genres") {
    MovieGenresView.previewGenres.withPreviewNavigation()
}

#Preview("Empty Genres") {
    MovieGenresView.previewEmpty.withPreviewNavigation()
}

extension MovieGenresView {
    /// Shows a list of genre chips with links
    static var previewGenres: some View {
        MovieGenresView(genres: GenrePreviewData.genres)
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
