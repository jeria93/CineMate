//
//  DiscoverRowPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import Foundation

enum DiscoverRowPreviewData {
    /// Static mock data for previewing `DiscoverMovieRow`.
    /// Designed to represent different states like valid poster or missing image.
    static let dune = Movie(
        id: 438631,
        title: "Dune",
        overview: nil,
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )
    
    static let noPosterMovie = Movie(
        id: 777777,
        title: "Posterless Movie",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )
}
