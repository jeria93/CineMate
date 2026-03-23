//
//  MovieCreditsView+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

extension MovieCreditsView {

    /// Preview with full Star Wars credits (cast + crew).
    static var previewStarWars: some View {
        PreviewFactory.movieCreditsViewStarWars()
    }

    /// Preview with empty credits (no cast or crew).
    static var previewEmptyCredits: some View {
        PreviewFactory.movieCreditsViewEmpty()
    }

    /// Preview showing only the director in the crew list.
    static var previewOnlyDirector: some View {
        PreviewFactory.movieCreditsViewOnlyDirector()
    }

    /// Preview showing only a small list of cast members.
    static var previewOnlyCast: some View {
        PreviewFactory.movieCreditsViewOnlyCast()
    }
}

/// PreviewFactory for MovieCredits-related previews.
@MainActor
extension PreviewFactory {

    static func movieCreditsViewStarWars() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.starWarsCredits())
            .padding()
    }

    static func movieCreditsViewEmpty() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.emptyCredits)
            .padding()
    }

    static func movieCreditsViewOnlyDirector() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.onlyDirector)
            .padding()
    }

    static func movieCreditsViewOnlyCast() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.onlyCast)
            .padding()
    }
}
