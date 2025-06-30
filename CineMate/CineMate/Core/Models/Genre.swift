//
//  Genre.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-30.
//

import Foundation

struct Genre: Codable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}
