//
//  PersonMovieCardView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//


import SwiftUI

extension PersonMovieCardView {
    static var preview: some View {
        PersonMovieCardView(movie: PreviewData.markHamillMovieCredits.first!)
            .padding()
            .background(Color(.systemBackground))
    }
    
    static var previewMissingPoster: some View {
        PersonMovieCardView(
            movie: PersonMovieCredit(
                id: 1997,
                title: "Mystery Movie",
                character: nil,
                releaseDate: "2025-01-01",
                posterPath: nil,
                popularity: nil
            )
        )
        .padding()
        .background(Color(.systemBackground))
    }
    
    static var previewMissingTitle: some View {
        PersonMovieCardView(
            movie: PersonMovieCredit(
                id: 888,
                title: nil,
                character: "Detective John",
                releaseDate: "2024-12-12",
                posterPath: "/somepath.jpg",
                popularity: 42.0
            )
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
