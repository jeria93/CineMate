//
//  HorizontalMoviesScrollView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-25.
//

import SwiftUI

struct HorizontalMoviesScrollView: View {
    let filmography: [PersonMovieCredit]
    let movieViewModel: MovieViewModel?
    let maxVisible: Int = 10

    @State private var isExpanded = false

    init(filmography: [PersonMovieCredit], movieViewModel: MovieViewModel? = nil) {
        self.filmography = filmography
        self.movieViewModel = movieViewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(displayedMovies, id: \.uniqueKey) { movie in
                        PersonMovieCardView(movie: movie, movieViewModel: movieViewModel)
                    }

                    if !isExpanded, filmography.count > maxVisible {
                        ExpandMoreCardView(remaining: filmography.count - maxVisible) {
                            isExpanded = true
                        }
                    }
                }
                .padding(.horizontal)
            }

            if isExpanded, filmography.count > maxVisible {
                ExpandToggleButton(
                    isExpanded: isExpanded,
                    expandedLabel: "Show less",
                    collapsedLabel: "Show more",
                    systemImage: "chevron.up"
                ) {
                    isExpanded = false
                }
            }
        }
    }
}

#Preview {
    HorizontalMoviesScrollView(filmography: PersonPreviewData.movieCredits)
        .padding()
}

private extension HorizontalMoviesScrollView {
    var displayedMovies: [PersonMovieCredit] {
        isExpanded ? filmography : Array(filmography.prefix(maxVisible))
    }
}
