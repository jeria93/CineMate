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

        return SearchResultsList(
            movies: movies,
            favoriteViewModel: PreviewFactory.favoritesVM(with: Array(movies.prefix(2))),
            isLoadingNextPage: false,
            loadMoreAction: { _ in }
        )
    }
}
