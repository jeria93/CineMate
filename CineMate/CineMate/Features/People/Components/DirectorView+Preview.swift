//
//  DirectorView+Preview.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-29.
//

import SwiftUI

extension DirectorView {
    static var previewWithDirector: some View {
        DirectorView(
            director: PreviewData.directorNolan,
            repository: MockMovieRepository()
        )
        .padding()
    }

    static var previewNoDirector: some View {
        DirectorView(
            director: nil,
            repository: MockMovieRepository()
        )
        .padding()
    }
}
