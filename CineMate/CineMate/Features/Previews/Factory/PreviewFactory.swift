//
//  PreviewFactory.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-23.
//

import SwiftUI

/// Centralized namespace for all preview helpers.
enum PreviewFactory {
    static let repository = MockMovieRepository()
    static let recommendedMovies = SharedPreviewMovies.moviesList
}
