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
                HStack(spacing: 10) {
                    ForEach(genres, id: \.self) { genre in
                        // todo: hook up enum-based navigation
                        Text(genre)
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
                    }
                }
                .padding(.horizontal, 4)
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

/**
 MovieGenresView
 ---------------
 Horizontal list of “genre chips”.
 
 > **NOTE (tech debt)**
 > The view still uses `NavigationLink`.
 > When we migrate *all* navigation to **AppNavigator + AppRoute**,
 > replace the link with:
 >
 > ```swift
 > @EnvironmentObject private var navigator: AppNavigator
 >
 > Text(genre)
 >     .onTapGesture { navigator.goToGenre(genre) }
 > ```
 >
 > …and add `case genreDetails(String)` in `AppRoute`
 > plus a switch-branch in `RootView`.
 */
