//
//  DirectorView+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

/// Preview variations for `DirectorView`.
///
/// Simulates full and empty director data.
extension DirectorView {

    /// Preview with a known director (e.g. Nolan).
    static var previewWithDirector: some View {
        DirectorView(
            director: DirectorPreviewData.nolan,
            repository: MockMovieRepository()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview with no director data (empty state).
    static var previewNoDirector: some View {
        DirectorView(
            director: nil,
            repository: MockMovieRepository()
        )
        .padding()
        .background(Color(.systemBackground))
    }

    /// Preview with placeholder director (e.g. no profile image).
    static var previewPartialDirector: some View {
        DirectorView(
            director: DirectorPreviewData.partial,
            repository: MockMovieRepository()
        )
        .padding()
        .background(Color(.systemBackground))
    }
}
