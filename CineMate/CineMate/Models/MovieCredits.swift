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

struct CastMember: Codable {
    let name: String
    let character: String?
}

struct CrewMember: Codable {
    let name: String
    let job: String?
}
