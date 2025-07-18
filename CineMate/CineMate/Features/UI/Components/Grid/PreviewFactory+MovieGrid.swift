//
//  PreviewFactory+MovieGrid.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

extension PreviewFactory {
    static var movieGridDefault: MovieGridView {
        MovieGridView(movies: MovieGridPreviewData.shortList, onReachEnd: {})
    }

    static var movieGridLong: MovieGridView {
        MovieGridView(movies: MovieGridPreviewData.longList, onReachEnd: {})
    }

    static var movieGridEmpty: MovieGridView {
        MovieGridView(movies: [], onReachEnd: {})
    }
}
