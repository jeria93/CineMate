//
//  PersonDetail.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-21.
//

import Foundation

struct PersonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let birthday: String?
    let deathday: String?
    let biography: String?
    let placeOfBirth: String?
    let profilePath: String?
    let imdbId: String?
    let movieCredits: [Movie]

    var profileURL: URL? {
        guard let profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w300\(profilePath)")
    }
}
