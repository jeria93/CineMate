//
//  MovieGridView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-14.
//

import SwiftUI

struct MovieGridView: View {
    let movies: [Movie]
    let onReachEnd: () -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            spacing: 16
        ) {
            ForEach(movies) { movie in
                MoviePosterView(movie: movie)
                    .onAppear {
                        if movie == movies.last {
                            onReachEnd()
                        }
                    }
            }
        }
        .padding()
    }
}
