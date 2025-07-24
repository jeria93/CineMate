//
//  KnownForScrollView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

extension KnownForScrollView {
    /// Shows full scroll view with iconic roles
    static var previewFull: some View {
        KnownForScrollView(movies: PersonPreviewData.movieCredits)
            .padding()
            .background(Color(.systemBackground))
    }

    /// Shows fallback UI for empty data
    static var previewEmpty: some View {
        KnownForScrollView(movies: [])
            .padding()
            .background(Color(.systemBackground))
    }
    
    /// Shows partially filled preview with minimal data
    static var previewPartial: some View {
        KnownForScrollView(movies: [
            PersonMovieCredit(
                id: PreviewID.next(),
                title: "Mysterious Adventure",
                character: nil,
                releaseDate: "2025-01-01",
                posterPath: nil,
                popularity: nil
            )
        ])
        .padding()
        .background(Color(.systemBackground))
    }

    /// Shows many iconic roles to test scroll performance and layout
    static var previewOverflow: some View {
        let manyMovies = (1...25).map { i in
            PersonMovieCredit(
                id: PreviewID.next(),
                title: "Movie \(i)",
                character: nil,
                releaseDate: "20\(10 + i)-01-01",
                posterPath: nil,
                popularity: Double.random(in: 10...100)
            )
        }

        return KnownForScrollView(movies: manyMovies)
            .padding()
            .background(Color(.systemBackground))
    }
}
