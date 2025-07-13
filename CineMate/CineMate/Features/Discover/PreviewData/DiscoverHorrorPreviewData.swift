//
//  DiscoverHorrorPreviewData.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-12.
//

import Foundation

/// Contains static mock horror movies used for previews.
/// These are injected into ViewModels to simulate horror-specific UI states.
struct DiscoverHorrorPreviewData {
    static let conjuring = Movie(
        id: 22222,
        title: "The Conjuring",
        overview: "Paranormal investigators help a family terrorized by a dark presence.",
        posterPath: "/wVYREutTvI2tmxr6ujrHT704wGF.jpg",
        backdropPath: "/qKkFk9HELmABpcPoc1HHZGIxQ5a.jpg",
        releaseDate: "2013-07-19",
        voteAverage: 7.5,
        genres: ["Horror", "Thriller"]
    )
    
    static let hereditary = Movie(
        id: 33333,
        title: "Hereditary",
        overview: "A grieving family is haunted by tragic and disturbing occurrences.",
        posterPath: "/g4VxE3b060xMFxoos53CcB2LzMk.jpg",
        backdropPath: "/p9ZUzCyy9wRTDuuQexkQ78R2BgF.jpg",
        releaseDate: "2018-06-08",
        voteAverage: 7.3,
        genres: ["Horror", "Drama", "Mystery"]
    )

    static let insidious = Movie(
        id: 44444,
        title: "Insidious",
        overview: "A family looks to prevent evil spirits from trapping their comatose child.",
        posterPath: "/tmlDFIUpGRKiuWm9Ixc6CYDk4y0.jpg",
        backdropPath: "/v7FvjabP3pYNucOdduXYqd2fB6h.jpg",
        releaseDate: "2011-04-01",
        voteAverage: 6.9,
        genres: ["Horror", "Thriller"]
    )

    /// A grouped array of horror mock movies for quick use in ViewModels.
    static let horrorMovies = [conjuring, hereditary, insidious]
}
