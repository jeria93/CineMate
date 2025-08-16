//
//  SearchResultsList+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-16.
//

import SwiftUI

extension SearchResultsList {

    /// Preview with a list of common mock movies and a couple marked as favorites.
    static var previewDefault: some View {
        SharedPreviewMovies.resetIDs()
        let movies = SharedPreviewMovies.moviesList
        // Mark the first two items as favorites for visual verification
        let favIDs = Set(movies.prefix(2).map { $0.id })

        return SearchResultsList(
            movies: movies,
            favoriteIDs: favIDs,
            onToggleFavorite: { _ in },
            loadMoreAction: { _ in }
        )
    }
}
