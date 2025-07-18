//
//  MovieGridPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-18.
//

import Foundation

enum MovieGridPreviewData {

    static let shortList: [Movie] = [
        SharedPreviewMovies.inception,
        SharedPreviewMovies.dune,
        SharedPreviewMovies.matrix
    ]

    static let longList: [Movie] = SharedPreviewMovies.moviesList + SharedPreviewMovies.moviesList

}
