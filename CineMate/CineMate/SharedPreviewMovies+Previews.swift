//
//  SharedPreviewMovies+Previews.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-15.
//

import Foundation

extension SharedPreviewMovies {
    static func resetIDs() {
        PreviewID.reset()
        _ = moviesList
    }
}
