//
//  SearchResultsList.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

/// Scrollable list of search results with infinite scroll support.
struct SearchResultsList: View {
    let movies: [Movie]
    let favoriteIDs: Set<Int>
    let onToggleFavorite: (Movie) -> Void
    let loadMoreAction: (Movie) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(movies) { movie in
                    MovieRowView(
                        movie: movie,
                        isFavorite: favoriteIDs.contains(movie.id),
                        onToggleFavorite: { onToggleFavorite(movie) }
                    )
                }

                // Sentinel: triggs "load more" when last cell appears
                if let last = movies.last {
                    Color.clear
                        .frame(height: 1)
                        .onAppear { loadMoreAction(last) }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Default") {
    SearchResultsList.previewDefault.withPreviewNavigation()
}
