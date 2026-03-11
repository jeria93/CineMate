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
    let isLoadingNextPage: Bool
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
                    .onAppear {
                        guard isPaginationTrigger(movie) else { return }
                        loadMoreAction(movie)
                    }
                }

                if isLoadingNextPage {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }

    private func isPaginationTrigger(_ movie: Movie) -> Bool {
        guard let index = movies.firstIndex(where: { $0.id == movie.id }) else { return false }
        return index >= max(movies.count - 3, 0)
    }
}

#Preview("Default") {
    SearchResultsList.previewDefault.withPreviewNavigation()
}
