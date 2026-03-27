//
//  RelatedMoviesSection.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-13.
//

import SwiftUI

struct RelatedMoviesSection: View {
    let movies: [Movie]
    let movieViewModel: MovieViewModel?
    
    private var uniqueMovies: [Movie] {
        movies.removingDuplicateIDs()
    }
    
    init(movies: [Movie], movieViewModel: MovieViewModel? = nil) {
        self.movies = movies
        self.movieViewModel = movieViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("You might also like")
                .font(.title2.bold())
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal)
            
            if uniqueMovies.isEmpty {
                HStack {
                    Image(systemName: "film")
                        .foregroundStyle(Color.appTextSecondary)
                    Text("No recommendations available.")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(uniqueMovies) { movie in
                            RelatedMovieCardView(movie: movie, movieViewModel: movieViewModel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview("With Mock Movies") {
    RelatedMoviesSection.previewWithMovies.withPreviewNavigation()
}

#Preview("Empty State") {
    RelatedMoviesSection.previewEmpty.withPreviewNavigation()
}

#Preview("Single Movie") {
    RelatedMoviesSection.previewSingleMovie.withPreviewNavigation()
}

#Preview("Many Movies") {
    RelatedMoviesSection.previewManyMovies.withPreviewNavigation()
}
