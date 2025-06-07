//
//  Movie.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-07.
//

import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let realeaseDate: String?
    let voteAverage: Double?
}

struct MovieResult: Codable {
    let results: [Movie]
}
