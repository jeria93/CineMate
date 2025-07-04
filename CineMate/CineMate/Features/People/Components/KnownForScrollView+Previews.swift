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
        KnownForScrollView(movies: PreviewData.markHamillMovieCredits)
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
                id: 999,
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
}
