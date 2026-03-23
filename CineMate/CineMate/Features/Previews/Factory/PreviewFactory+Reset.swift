//
//  PreviewFactory+Reset.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-17.
//

import Foundation

/// Centralized reset method for all preview-related data
extension PreviewFactory {
    static func resetAllPreviewData() {
        // Deterministic preview IDs no longer require resetting mutable counters.
        _ = SharedPreviewMovies.moviesList
        _ = MovieCreditsPreviewData.starWarsCredits()
        _ = DiscoverPreviewData.movies
        _ = DiscoverHorrorPreviewData.horrorMovies
    }
}
