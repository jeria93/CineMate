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
            MovieRowView(movie: movie)
        }
        .listStyle(.plain)
    }
}

#Preview("Default") {
    SearchResultsList.previewDefault
}

#Preview("Empty") {
    SearchResultsList.previewEmpty
}
