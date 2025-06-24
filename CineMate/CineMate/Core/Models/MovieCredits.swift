//
//  MovieCredits.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-11.
//

import Foundation

struct MovieCredits: Codable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

//Bryt ut denna till sin egna fil.
struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}

struct CrewMember: Codable {
    let name: String
    let job: String?
}
