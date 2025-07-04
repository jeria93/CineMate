//
//  MovieCreditsView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieCreditsView {
    static var previewStarWars: some View {
        MovieCreditsView(credits: PreviewData.starWarsCredits)
            .padding()
    }

    static var previewEmptyCredits: some View {
        let empty = MovieCredits(id: 0, cast: [], crew: [])
        return MovieCreditsView(credits: empty)
            .padding()
    }

    static var previewOnlyDirector: some View {
        let credits = MovieCredits(
            id: 1,
            cast: [],
            crew: [CrewMember(id: 1, name: "Christopher Nolan", job: "Director", profilePath: nil)]
        )
        return MovieCreditsView(credits: credits)
            .padding()
    }

    static var previewOnlyCast: some View {
        let credits = MovieCredits(
            id: 2,
            cast: [
                CastMember(id: 1, name: "Actor A", character: nil, profilePath: nil),
                CastMember(id: 2, name: "Actor B", character: nil, profilePath: nil)
            ],
            crew: []
        )
        return MovieCreditsView(credits: credits)
            .padding()
    }
}
