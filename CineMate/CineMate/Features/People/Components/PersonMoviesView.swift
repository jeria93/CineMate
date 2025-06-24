//
//  PersonMoviesView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-22.
//

import SwiftUI

struct PersonMoviesView: View {
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Movies")
                .font(.headline)
            
            ForEach(movies) { movie in
                VStack(alignment: .leading) {
                    
                    Text(movie.title)
                        .font(.subheadline)
                        .bold()
                    
                    if let date = movie.releaseDate {
                        Text("Released: \(date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
}

#Preview("Movies – Mark Hamill") {
    PersonMoviesView(movies: PreviewData.markHamillMovies)
}
