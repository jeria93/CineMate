//
//  MovieVideo.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-06-12.
//

import Foundation

struct MovieVideo: Identifiable, Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

struct MovieVideoResult: Codable {
    let results: [MovieVideo]
}
