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
        PreviewFactory.movieCreditsView_StarWars()
    }

    /// Preview with empty credits (no cast or crew).
    static var previewEmptyCredits: some View {
        PreviewFactory.movieCreditsView_Empty()
    }

    /// Preview showing only the director in the crew list.
    static var previewOnlyDirector: some View {
        PreviewFactory.movieCreditsView_OnlyDirector()
    }

    /// Preview showing only a small list of cast members.
    static var previewOnlyCast: some View {
        PreviewFactory.movieCreditsView_OnlyCast()
    }
}

/// PreviewFactory for MovieCredits-related previews.
@MainActor
extension PreviewFactory {

    static func movieCreditsView_StarWars() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.starWarsCredits())
            .padding()
    }

    static func movieCreditsView_Empty() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.emptyCredits)
            .padding()
    }

    static func movieCreditsView_OnlyDirector() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.onlyDirector)
            .padding()
    }

    static func movieCreditsView_OnlyCast() -> some View {
        MovieCreditsView(credits: MovieCreditsPreviewData.onlyCast)
            .padding()
    }
}
