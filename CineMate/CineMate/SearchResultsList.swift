//
//  SearchResultsList.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct SearchResultsList: View {
    let movies: [Movie]

    var body: some View {
        List(movies) { movie in
            Text(movie.title)
        }
    }
}

#Preview("SearchResultsList") {
    SearchResultsList(movies: PreviewData.moviesList)
}
